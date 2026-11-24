    print(f"总 DLL 体积: {total_size / 1024 / 1024:.2f} MB\n")

    # 参考项目对比
    print("[对比参考] 参考项目的 DLL 情况:")
    print("  - 总数量: 71 个")
    print("  - 总体积: 93.23 MB")
    print("  - 最大的: libopenblas (26.85 MB), opengl32sw (15.25 MB)\n")

    # 分析大于 3MB 的 DLL
    large_dlls = [(dll, size) for dll, size in dll_data if size > 3 * 1024 * 1024]

    if large_dlls:
        print("=" * 70)
        print("WARNING:  大于 3MB 的 DLL（需重点关注）")
        print("=" * 70)

        for dll, size in large_dlls:
            size_mb = size / 1024 / 1024
            relative_path = dll.relative_to(dist_dir)
            name_lower = dll.name.lower()

            print(f"\n{size_mb:8.2f} MB  {dll.name}")
            print(f"           位置: {relative_path.parent}")

            # 优化建议
            suggestions = get_optimization_suggestion(name_lower)
            if suggestions:
                for suggestion in suggestions:
                    print(f"            {suggestion}")

    # 检查冗余 DLL
    print("\n" + "=" * 70)
    print(" 冗余检查")
    print("=" * 70)

    # 检查调试版本
    debug_dlls = [dll for dll, _ in dll_data if dll.stem.endswith('d')]
    if debug_dlls:
        print(f"\nWARNING:  发现 {len(debug_dlls)} 个调试版本 DLL（可以删除）:")
        for dll in debug_dlls:
            print(f"  - {dll.name}")
    else:
        print("\nPASS: 未发现调试版本 DLL（已优化）")

    # VC++ Runtime
    vc_runtimes = [dll for dll, _ in dll_data if 'vcruntime' in dll.name.lower() or 'msvcp' in dll.name.lower()]
    if vc_runtimes:
        print(f"\n[VC++ Runtime 库] 发现 {len(vc_runtimes)} 个:")
        for dll in vc_runtimes:
            size_mb = dll.stat().st_size / 1024 / 1024
            print(f"  - {dll.name} ({size_mb:.2f} MB)")
        print("   这些是必需的，参考项目也包含了这些文件")

    # 全部 DLL 列表
    print("\n" + "=" * 70)
    print(" 完整 DLL 列表（按体积排序，前 20）")
    print("=" * 70)
    print(f"\n{'体积 (MB)':>10}  {'文件名':<30}  位置")
    print("-" * 70)

    for dll, size in dll_data[:20]:
        size_mb = size / 1024 / 1024
        relative_path = dll.relative_to(dist_dir)
        location = str(relative_path.parent) if relative_path.parent != Path('.') else "根目录"
        print(f"{size_mb:10.2f}  {dll.name:<30}  {location}")

    if len(dll_data) > 20:
        remaining_size = sum(size for _, size in dll_data[20:]) / 1024 / 1024
        print(f"... 还有 {len(dll_data) - 20} 个 DLL，共 {remaining_size:.2f} MB")


def get_optimization_suggestion(dll_name: str) -> list:
    """根据 DLL 名称给出优化建议"""
    suggestions = []

    if "openblas" in dll_name or "mkl" in dll_name:
        suggestions.append("数学运算库，参考项目的 libopenblas 有 26.85 MB")
        suggestions.append("如不需要高性能计算可考虑轻量版")

    elif "opencv" in dll_name or "ffmpeg" in dll_name:
        suggestions.append("OpenCV 相关，参考项目的 opencv_videoio_ffmpeg 有 18.48 MB")
        suggestions.append("考虑用 opencv-python-headless")

    elif "qt5" in dll_name or "qt6" in dll_name or "pyside" in dll_name:
        suggestions.append("Qt 库，参考项目的 Qt5Core 有 5.13 MB")
        suggestions.append("可排除不需要的模块（WebEngine, 3D, Charts）")

    elif "opengl" in dll_name and "sw" in dll_name:
        suggestions.append("OpenGL 软件渲染器，参考项目保留了 15.25 MB")
        suggestions.append("通常可以删除（使用硬件渲染）")

    elif "d3dcompiler" in dll_name:
        suggestions.append("DirectX 编译器，参考项目有 3.53 MB")

    elif "mfc140" in dll_name:
        suggestions.append("MFC 库，参考项目有 4.89 MB")

    return suggestions


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python analyze_dlls.py <dist目录路径>")
        print("示例: python analyze_dlls.py dist/main.dist")
        sys.exit(1)

    analyze_dlls(sys.argv[1])
```

**使用方法**：
```bash
python analyze_dlls.py dist/你的软件名.dist
```

---

## 完整优化工作流

### 步骤 1：修改编译脚本配置

编辑 `build_optimized.bat`，修改这 3 行：

```batch
set APP_NAME=你的软件名      REM 改成实际名称
set MAIN_FILE=main.py        REM 你的主程序文件
set ICON_FILE=icon.ico       REM 你的图标文件
```

### 步骤 2：一键编译+瘦身

```bash
# 在项目根目录执行
build_optimized.bat
```

### 步骤 3：分析 DLL 依赖

```bash
python analyze_dlls.py dist/你的软件名.dist
```

### 步骤 4：根据分析结果优化

**如果用了 OpenCV** → 改用无头版
```bash
pip uninstall opencv-python
pip install opencv-python-headless
```

**如果用了 Qt** → 排除不需要的模块
```batch
# 在编译命令中添加
--nofollow-import-to=PyQt5.QtWebEngine,PyQt5.Qt3D,PyQt5.QtCharts
```

**删除软件渲染器**（如果不需要）
```powershell
# 在 dist 目录执行
Remove-Item "opengl32sw.dll" -Force
```

---

## VC++ 运行库处理方案

### 方案一：静态链接（推荐）
```bash
nuitka --static-libpython=yes ...
```

### 方案二：捆绑运行库安装（商业发布推荐）
在 Inno Setup 脚本中添加：

```iss
; WARNING: VC++ 运行库架构必须与 Python/Nuitka 构建架构一致。
; 本 skill 推荐 32 位 Python，故默认捆绑 vc_redist.x86.exe；
; 若用 64 位 Python 编译，请把下面两处改为 vc_redist.x64.exe。
[Files]
Source: "{#MySourceDir}\..\vc_redist.x86.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "{tmp}\vc_redist.x86.exe"; Parameters: "/quiet /norestart"; StatusMsg: "正在安装运行库..."; Flags: waituntilterminated
```

> 下载地址：[Microsoft Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)

---

## Inno Setup 脚本模板（商业终极版）

```iss
; =====================================================================
;  WARNING: 商业级 Python 安装脚本 (Inno Setup 6.x)
;  特性：LZMA2 极限压缩 | 全中文 | 完整元数据 | 无残留卸载
;  参考：参考项目(323 MB, LZMA2 压缩)
; =====================================================================

; --- 1. 参数定义 ---
#define MyAppName        "{{APP_NAME}}"
#define MyAppVersion     "{{APP_VERSION}}"
#define MyAppPublisher   "{{PUBLISHER}}"
#define MyAppURL         "{{APP_URL}}"
#define MyAppExeName     "{{EXE_NAME}}"
#define MySourceDir      "{{SOURCE_DIR}}"
#define MyOutputDir      "{{OUTPUT_DIR}}"
;#define MyIconPath      "{{ICON_PATH}}"

[Setup]
; --- 身份识别 ---
AppId={{GENERATE_RANDOM_GUID}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; --- 安装路径与权限 ---
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=no
PrivilegesRequired=admin

; --- 输出设置 ---
OutputDir={#MyOutputDir}
OutputBaseFilename=Setup_{#MyAppName}_v{#MyAppVersion}

; --- 视觉体验 ---
WizardStyle=modern
#ifdef MyIconPath
SetupIconFile={#MyIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}
#endif

; ---  核心压缩 (参考 参考项目) ---
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes

; --- 架构 ---
; 注意：仅 64 位 Python 构建才设此项。本 skill 推荐 32 位 Python——
; 32 位构建请保持注释，使应用按 32 位安装并与上面捆绑的 vc_redist.x86.exe 匹配。
; 仅当用 64 位 Python 编译时才取消注释。
;ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Icons]
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
```

---

## 占位符说明

| 占位符 | 说明 | 示例值 |
|--------|------|--------|
| `{{APP_NAME}}` | 软件显示名称 | `红墨批注` |
| `{{APP_VERSION}}` | 版本号 | `1.0.0` |
| `{{PUBLISHER}}` | 发布者/公司名 | `MyCompany` |
| `{{APP_URL}}` | 官网地址 | `https://example.com` |
| `{{EXE_NAME}}` | 主程序文件名 | `RedInk.exe` |
| `{{SOURCE_DIR}}` | Nuitka dist 文件夹路径 | `D:\project\dist\RedInk.dist` |
| `{{OUTPUT_DIR}}` | 安装包输出路径 | `D:\project\output` |
| `{{ICON_PATH}}` | 图标文件路径 | `D:\project\icon.ico` |
| `{{GENERATE_RANDOM_GUID}}` | **需生成唯一GUID** | 使用 Inno Setup "Tools > Generate GUID" |

---

## 常见问题 (FAQ)

### Q1: 安装后双击程序无反应？
1. 打开 CMD，手动运行 exe 查看错误信息
2. 检查是否缺少 VC++ 运行库
3. 检查 Nuitka 编译是否成功

### Q2: 安装包体积过大？
**优化方法**：
1. 使用 32 位 Python 编译（节省 20-30%）
2. 应用 参考项目的模块排除清单
3. 启用 Anti-Bloat 插件
4. 执行 dist 文件夹瘦身脚本
5. 分析 DLL，移除不必要的大文件

### Q3: 杀毒软件误报？
**解决方案**：
- 提交到主流杀毒厂商进行白名单申请
- 购买代码签名证书（推荐：Sectigo, DigiCert）
- 避免使用 UPX 压缩

### Q4: 安装时提示 Windows 已保护你的电脑？
- 购买 EV 代码签名证书（可立即获得信任）
- 普通代码签名证书需要积累安装量后逐渐获得信任

---

## 实战问题处理记录（更新 2026-02-07）

- **安装后提示缺少 python3xx.dll**：必须使用 Nuitka `--standalone`；确认 dist 内存在该 dll；不要打单文件版。
- **安装后点击无反应**：GUI 启动期可能被重依赖阻塞；将重依赖延迟到"开始导出"再 import；添加日志排查。
- **Nuitka + MinGW 在非 ASCII 路径报错**：把源码复制到 ASCII 目录再编译；设置 `PYTHONIOENCODING=utf-8`。
- **Inno Setup 警告 `x64` 已弃用（仅 64 位构建需要 64 位安装模式时）**：改为 `ArchitecturesInstallIn64BitMode=x64compatible`；32 位构建无需此项。
- **`--disable-console` 已废弃**：改用 `--windows-console-mode=disable`。
- **dist 出现 `_nuitka_temp.exe`**：在 [Files] 中排除它。

---

## 优化效果预期

| 优化组合 | 体积减少 | 启动提升 | 风险等级 |
|----------|----------|----------|----------|
| 基础编译 | 基准 | 基准 | 无 |
| + `--lto=yes` | 5-10% | 10-20% | PASS: 无 |
| + anti-bloat | 15-25% | - | PASS: 无 |
| + 模块排除 | 20-35% | 5% | PASS: 无 |
| + dist 瘦身 | 25-40% | - | PASS: 无 |
| + 32 位编译 | 40-60% | - | PASS: 无 |
| **全部组合** | **45-65%** | **15-25%** | PASS: **无风险** |

> WARNING: **不建议使用 UPX 压缩**，虽然能进一步减小体积，但极易触发杀毒软件误报。

---

**基于 参考项目实战经验优化，助你打造商业级安装包！**
