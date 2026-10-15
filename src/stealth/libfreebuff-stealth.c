#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <netpacket/packet.h>
#include <sys/utsname.h>

/*
 * ==============================================================================
 * 🛡️ LIBFREEBUFF-STEALTH — Hardware Identity & Telemetry Virtualization Hook
 * ==============================================================================
 * Intercepts low-level libc system calls to dynamically virtualize:
 * 1. Linux machine-id (/etc/machine-id & /var/lib/dbus/machine-id)
 * 2. Hardware MAC addresses (getifaddrs & /sys/class/net/x/address)
 * 3. DMI Product UUID & Serial (/sys/class/dmi/id/product_uuid)
 * 4. System Hostname (uname & gethostname)
 *
 * Guarantees zero hardware correlation across accounts and prevents ban cascades.
 * ==============================================================================
 */

static int (*real_open)(const char *pathname, int flags, ...) = NULL;
static int (*real_open64)(const char *pathname, int flags, ...) = NULL;
static int (*real_openat)(int dirfd, const char *pathname, int flags, ...) = NULL;
static int (*real_openat64)(int dirfd, const char *pathname, int flags, ...) = NULL;
static int (*real_getifaddrs)(struct ifaddrs **ifap) = NULL;
static int (*real_uname)(struct utsname *buf) = NULL;
static int (*real_gethostname)(char *name, size_t len) = NULL;

static void __attribute__((constructor)) init_hooks(void) {
    real_open = dlsym(RTLD_NEXT, "open");
    real_open64 = dlsym(RTLD_NEXT, "open64");
    if (!real_open64) real_open64 = real_open;
    real_openat = dlsym(RTLD_NEXT, "openat");
    real_openat64 = dlsym(RTLD_NEXT, "openat64");
    if (!real_openat64) real_openat64 = real_openat;
    real_getifaddrs = dlsym(RTLD_NEXT, "getifaddrs");
    real_uname = dlsym(RTLD_NEXT, "uname");
    real_gethostname = dlsym(RTLD_NEXT, "gethostname");
}

static const char* resolve_override(const char *pathname) {
    if (!pathname) return NULL;

    const char *home = getenv("HOME");
    static char fallback_machine_id[512] = {0};
    static char fallback_mac[512] = {0};
    static char fallback_uuid[512] = {0};
    static char fallback_serial[512] = {0};

    if (strcmp(pathname, "/etc/machine-id") == 0 || strcmp(pathname, "/var/lib/dbus/machine-id") == 0) {
        const char *env_path = getenv("FREEBUFF_SPOOFED_MACHINE_ID_PATH");
        if (env_path && access(env_path, R_OK) == 0) return env_path;
        if (home) {
            snprintf(fallback_machine_id, sizeof(fallback_machine_id), "%s/.config/manicode/spoofed-machine-id", home);
            if (access(fallback_machine_id, R_OK) == 0) return fallback_machine_id;
        }
    }

    if (strstr(pathname, "/sys/class/net/") && strstr(pathname, "/address")) {
        const char *env_mac = getenv("FREEBUFF_SPOOFED_MAC_PATH");
        if (env_mac && access(env_mac, R_OK) == 0) return env_mac;
        if (home) {
            snprintf(fallback_mac, sizeof(fallback_mac), "%s/.config/manicode/spoofed-mac", home);
            if (access(fallback_mac, R_OK) == 0) return fallback_mac;
        }
    }

    if (strcmp(pathname, "/sys/class/dmi/id/product_uuid") == 0) {
        const char *env_uuid = getenv("FREEBUFF_SPOOFED_UUID_PATH");
        if (env_uuid && access(env_uuid, R_OK) == 0) return env_uuid;
        if (home) {
            snprintf(fallback_uuid, sizeof(fallback_uuid), "%s/.config/manicode/spoofed-product-uuid", home);
            if (access(fallback_uuid, R_OK) == 0) return fallback_uuid;
        }
    }

    if (strcmp(pathname, "/sys/class/dmi/id/product_serial") == 0) {
        const char *env_ser = getenv("FREEBUFF_SPOOFED_SERIAL_PATH");
        if (env_ser && access(env_ser, R_OK) == 0) return env_ser;
        if (home) {
            snprintf(fallback_serial, sizeof(fallback_serial), "%s/.config/manicode/spoofed-product-serial", home);
            if (access(fallback_serial, R_OK) == 0) return fallback_serial;
        }
    }

    return NULL;
}

int open(const char *pathname, int flags, ...) {
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args;
        va_start(args, flags);
        mode = va_arg(args, mode_t);
        va_end(args);
    }
    const char *target = resolve_override(pathname);
    return real_open(target ? target : pathname, flags, mode);
}

int open64(const char *pathname, int flags, ...) {
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args;
        va_start(args, flags);
        mode = va_arg(args, mode_t);
        va_end(args);
    }
    const char *target = resolve_override(pathname);
    return real_open64 ? real_open64(target ? target : pathname, flags, mode) : real_open(target ? target : pathname, flags, mode);
}

int openat(int dirfd, const char *pathname, int flags, ...) {
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args;
        va_start(args, flags);
        mode = va_arg(args, mode_t);
        va_end(args);
    }
    const char *target = resolve_override(pathname);
    return real_openat(dirfd, target ? target : pathname, flags, mode);
}

int openat64(int dirfd, const char *pathname, int flags, ...) {
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args;
        va_start(args, flags);
        mode = va_arg(args, mode_t);
        va_end(args);
    }
    const char *target = resolve_override(pathname);
    return real_openat64 ? real_openat64(dirfd, target ? target : pathname, flags, mode) : real_openat(dirfd, target ? target : pathname, flags, mode);
}

int getifaddrs(struct ifaddrs **ifap) {
    if (!real_getifaddrs) real_getifaddrs = dlsym(RTLD_NEXT, "getifaddrs");
    int ret = real_getifaddrs(ifap);
    if (ret != 0 || !ifap || !*ifap) return ret;

    const char *mac_str = getenv("FREEBUFF_SPOOFED_MAC_ADDRESS");
    if (!mac_str) {
        const char *home = getenv("HOME");
        static char fallback_mac_file[512] = {0};
        static char cached_mac[32] = {0};
        if (home && cached_mac[0] == '\0') {
            snprintf(fallback_mac_file, sizeof(fallback_mac_file), "%s/.config/manicode/spoofed-mac", home);
            FILE *f = fopen(fallback_mac_file, "r");
            if (f) {
                if (fgets(cached_mac, sizeof(cached_mac), f)) {
                    cached_mac[strcspn(cached_mac, "\r\n")] = '\0';
                }
                fclose(f);
            }
        }
        if (cached_mac[0] != '\0') mac_str = cached_mac;
    }

    if (!mac_str) return ret;

    unsigned char m[6];
    if (sscanf(mac_str, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", &m[0], &m[1], &m[2], &m[3], &m[4], &m[5]) != 6) {
        return ret;
    }

    for (struct ifaddrs *ifa = *ifap; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr && ifa->ifa_addr->sa_family == AF_PACKET) {
            struct sockaddr_ll *s = (struct sockaddr_ll *)ifa->ifa_addr;
            if (s->sll_halen == 6 && (s->sll_addr[0] || s->sll_addr[1] || s->sll_addr[2])) {
                memcpy(s->sll_addr, m, 6);
            }
        }
    }
    return ret;
}

int uname(struct utsname *buf) {
    if (!real_uname) real_uname = dlsym(RTLD_NEXT, "uname");
    int ret = real_uname(buf);
    if (ret == 0 && buf) {
        const char *fake_host = getenv("FREEBUFF_SPOOFED_HOSTNAME");
        if (fake_host && fake_host[0] != '\0') {
            strncpy(buf->nodename, fake_host, sizeof(buf->nodename) - 1);
            buf->nodename[sizeof(buf->nodename) - 1] = '\0';
        }
    }
    return ret;
}

int gethostname(char *name, size_t len) {
    if (!real_gethostname) real_gethostname = dlsym(RTLD_NEXT, "gethostname");
    const char *fake_host = getenv("FREEBUFF_SPOOFED_HOSTNAME");
    if (fake_host && fake_host[0] != '\0') {
        strncpy(name, fake_host, len - 1);
        name[len - 1] = '\0';
        return 0;
    }
    return real_gethostname(name, len);
}
