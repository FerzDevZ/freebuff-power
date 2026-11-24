---
name: openmp-cpp-component-sdk
description: Developing high-performance C++ components and native extensions for open.mp using the official open.mp C++ SDK (openmultiplayer/open.mp-sdk) — Component lifecycle, AMX native binding, event dispatcher subscriptions, and CMake/Conan cross-platform compilation.
---

# open.mp C++ Component SDK Skill

## Architecture Overview
open.mp replaces legacy binary hacking with a modular **Component-Based Architecture**. Components are loaded dynamically by the open.mp core and communicate through standardized C++ interfaces (`IComponent`).

### Repository & SDK References
- Core SDK: `openmultiplayer/open.mp-sdk`
- Template: `openmultiplayer/full-template`
- C-API: `openmultiplayer/open.mp-capi`

## Component Structure & Lifecycle
A production open.mp component implements `IComponent` and any relevant event interfaces:

```cpp
// src/DiscordBridgeComponent.hpp
#pragma once
#include <sdk.hpp>
#include <Server/Components/Pawn/pawn.hpp>
#include <Server/Components/Vehicles/vehicles.hpp>

class DiscordBridgeComponent final : 
    public IComponent, 
    public PawnEventHandler,
    public PlayerConnectEventHandler 
{
public:
    static inline UID ComponentUID = 0x5a4d5001; // Unique 32-bit component ID

    StringView componentName() const override { return "DiscordBridge"; }
    SemanticVersion componentVersion() const override { return SemanticVersion(1, 0, 0, 0); }

    // Component Lifecycle Hooks
    void onLoad(ICore* c) override {
        core_ = c;
    }

    void onInit(IComponentList* components) override {
        pawn_ = components->queryComponent<IPawnComponent>();
        if (pawn_) {
            pawn_->getEventDispatcher().addEventHandler(this);
        }
        core_->getPlayers().getPlayerConnectDispatcher().addEventHandler(this);
    }

    void onReady() override {
        core_->printLn("[DiscordBridge] Component loaded and ready.");
    }

    void onFree() override {
        if (pawn_) {
            pawn_->getEventDispatcher().removeEventHandler(this);
        }
        core_->getPlayers().getPlayerConnectDispatcher().removeEventHandler(this);
    }

    void reset() override {}

    // Event Handlers
    void onAmxLoad(IPawnScript& script) override;
    void onAmxUnload(IPawnScript& script) override {}
    bool onPlayerConnect(IPlayer& player) override;

private:
    ICore* core_ = nullptr;
    IPawnComponent* pawn_ = nullptr;
};
```

## AMX Native Function Registration
Exposing custom C++ functions to Pawn scripts:

```cpp
// Native declaration in Pawn:
// native bool:Discord_SendMessage(const channel[], const message[]);

static cell AMX_NATIVE_CALL n_Discord_SendMessage(AMX* amx, cell* params) {
    if (params[0] != 2 * sizeof(cell)) {
        return 0; // Wrong parameter count
    }

    cell* channelAddr = nullptr;
    cell* messageAddr = nullptr;
    amx_GetAddr(amx, params[1], &channelAddr);
    amx_GetAddr(amx, params[2], &messageAddr);

    int channelLen = 0, messageLen = 0;
    amx_StrLen(channelAddr, &channelLen);
    amx_StrLen(messageAddr, &messageLen);

    std::string channel(channelLen, '\0');
    std::string message(messageLen, '\0');
    amx_GetString(channel.data(), channelAddr, 0, channelLen + 1);
    amx_GetString(message.data(), messageAddr, 0, messageLen + 1);

    // Call underlying async C++ HTTP / WebSocket client
    bool dispatched = SendToDiscordWebhook(channel, message);
    return dispatched ? 1 : 0;
}

const AMX_NATIVE_INFO g_DiscordNatives[] = {
    {"Discord_SendMessage", n_Discord_SendMessage},
    {nullptr, nullptr}
};

void DiscordBridgeComponent::onAmxLoad(IPawnScript& script) {
    pawn_->registerNatives(script, g_DiscordNatives);
}
```

## Core Event Dispatching
Subscribing to native open.mp player actions without overriding AMX callbacks:

```cpp
bool DiscordBridgeComponent::onPlayerConnect(IPlayer& player) {
    std::string name = std::string(player.getName());
    int id = player.getID();

    core_->printLn("[EVENT] Player %s (ID: %d) joined the server.", name.c_str(), id);

    // Return true to allow connection, false to reject
    return true;
}
```

## Modern CMake Build System (`CMakeLists.txt`)
```cmake
cmake_minimum_required(VERSION 3.20)
project(DiscordBridge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(lib/open.mp-sdk)

add_library(DiscordBridge SHARED
    src/DiscordBridgeComponent.hpp
    src/DiscordBridgeComponent.cpp
    src/main.cpp
)

target_include_directories(DiscordBridge PRIVATE src)
target_link_libraries(DiscordBridge PRIVATE open.mp-sdk)

if(MSVC)
    target_compile_options(DiscordBridge PRIVATE /W4 /permissive-)
else()
    target_compile_options(DiscordBridge PRIVATE -Wall -Wextra -Wpedantic -fPIC -m32 -O3)
endif()

set_target_properties(DiscordBridge PROPERTIES PREFIX "")
```

## Cross-Platform Compilation Pipeline
```bash
# Linux 32-bit build (standard open.mp server target)
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-m32"
cmake --build . --config Release -j$(nproc)

# Output library:
# Linux:   components/DiscordBridge.so
# Windows: components/DiscordBridge.dll
```

## Runtime (open.mp 2026)

- **open.mp server**: v1.6.7.3218 (latest stable, Oct 2026)
- **open.mp C++ SDK**: `openmultiplayer/open.mp-sdk` (C++20, component ABI stable across 1.6.x)
- **Toolchain**: GCC 13+/Clang 17+ or MSVC 19.38+, `-m32` for the 32-bit server ABI
- **CMake**: 3.28+ (`cmake --build build --config Release`), Conan 2.x optional
- **Pawn side**: pawncc 3.10.10+ calling your natives; `-Z` treats warnings as errors

### Component Build Gate
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-m32 -Wall -Wextra -Wpedantic"
cmake --build build --config Release -j"$(nproc)"
# must emit components/<Name>.so (Linux) or .dll (Windows) with zero warnings
```
