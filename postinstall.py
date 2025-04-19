#!/usr/bin/env python3
import os
import shutil
import sys
import subprocess

EXEFLAG_NONE = 0x0000
EXEFLAG_LINUX = 0x0001
EXEFLAG_WINDOWS = 0x0002
EXEFLAG_MACOS = 0x0004
EXEFLAG_MACOS_FAT = 0x0008
EXEFLAG_32BITS = 0x0010
EXEFLAG_64BITS = 0x0020
# Keep signatures sorted by size
_EXE_SIGNATURES = (
    (b"\x4D\x5A", EXEFLAG_WINDOWS),
    (b"\xCE\xFA\xED\xFE", EXEFLAG_MACOS | EXEFLAG_32BITS),
    (b"\xCF\xFA\xED\xFE", EXEFLAG_MACOS | EXEFLAG_64BITS),
    (b"\xBE\xBA\xFE\xCA", EXEFLAG_MACOS | EXEFLAG_32BITS | EXEFLAG_MACOS_FAT),
    (b"\xBF\xBA\xFE\xCA", EXEFLAG_MACOS | EXEFLAG_64BITS | EXEFLAG_MACOS_FAT),
    (b"\x7F\x45\x4C\x46\x01", EXEFLAG_LINUX | EXEFLAG_32BITS),
    (b"\x7F\x45\x4C\x46\x02", EXEFLAG_LINUX | EXEFLAG_64BITS)
)


def get_exeflags(file):
    with open(file, "rb") as f:
        buf = b""
        buf_len = 0
        for sig, flags in _EXE_SIGNATURES:
            sig_len = len(sig)
            if buf_len < sig_len:
                buf += f.read(sig_len - buf_len)
                buf_len = sig_len
            if buf == sig:
                return flags
    return EXEFLAG_NONE


def is_linux_binary(file):
    flag = get_exeflags(file)
    ret = flag & EXEFLAG_LINUX != 0
    return ret


def is_elf(file):
    ok = os.path.isfile(file)
    return ok and is_linux_binary(file)


def get_output(command):
    return subprocess.check_output(command, universal_newlines=True).strip()


def which(name):
    return get_output(["which" if is_linux else "where", name]).split("\n")


def check_call(args):
    print(" ".join(p if " " not in p else "'" + p + "'" for p in args), flush=True)
    subprocess.check_call(args)


def read_file(name):
    with open(name) as f:
        return f.read()


def ensure_dir(name):
    dir_ = os.path.dirname(name)
    if dir_ and not os.path.exists(dir_):
        os.makedirs(dir_)
    return dir_


def write_file(name, data):
    ensure_dir(name)
    with open(name, "w") as f:
        return f.write(data)


def get_rpath(file):
    try:
        s = get_output(["chrpath", file]).split()
        if len(s) == 2:
            return s[1]
    except subprocess.CalledProcessError:
        pass
    return ""


def set_rpath(file):
    if not is_rpath or not is_elf(file):
        return
    file = os.path.realpath(file)
    file = os.path.relpath(file)
    parts = file.split("/")
    is_debug = "debug" in parts
    origin = f"$ORIGIN:$ORIGIN/../lib:$ORIGIN/.."
    if len(parts) > 2:
        origin += f":$ORIGIN/{'/'.join(['..'] * (len(parts) - 1))}{'/debug' if is_debug else ''}/lib"
    current = get_rpath(file)
    if current == f"RPATH={origin}":
        return
    check_call(["patchelf", "--set-rpath", origin, file])
    check_call(["bin/runpath2rpath", file])


def ensure_link_full(name, source):
    if not os.path.exists(source):
        return
    set_rpath(source)
    if os.path.islink(name) and not os.path.exists(name):
        os.remove(name)
    if os.path.isfile(name) and not os.path.islink(name):
        os.remove(name)
    if os.path.exists(name):
        return
    dir_ = ensure_dir(name)
    rel_source = os.path.relpath(source, dir_)
    os.symlink(rel_source, name, target_is_directory=os.path.isdir(source))


def ensure_link(dir_, source):
    ensure_link_full(os.path.join(dir_, os.path.basename(source)), source)


def ensure_file(name, data):
    if not os.path.exists(name):
        write_file(name, data)


def qt_conf_one(name, content):
    if os.path.exists(name):
        content = read_file(name)
    if "${CURRENT_INSTALLED_DIR}" in content:
        write_file(name, content.replace("CURRENT_HOST_INSTALLED_DIR", "CURRENT_INSTALLED_DIR").replace(
            "${CURRENT_INSTALLED_DIR}", cwd.replace("\\", "/")))
    return content


def qt_conf(f1, f2, content):
    content = qt_conf_one(f1, content)
    qt_conf_one(f2, content)


def glob_rpath():
    for root, dirnames, filenames in os.walk("."):
        for filename in filenames:
            try:
                set_rpath(os.path.join(root, filename))
            except subprocess.CalledProcessError:
                pass


cwd = os.getcwd()
if os.path.exists("debug/lib/cmake"):
    shutil.rmtree("debug/lib/cmake")

qt_conf("tools/Qt6/qt_release.conf", "bin/qt.conf", """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Headers=include/Qt6/
Libraries=lib
Plugins=Qt6/plugins
Qml2Imports=Qt6/qml
Documentation=doc/Qt6/
Binaries=bin
LibraryExecutables=tools/Qt6/bin
ArchData=share/Qt6
Data=share/Qt6
Translations=translations/Qt6/
Examples=share/examples/Qt6/
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Headers=include/Qt6/
Libraries=lib
Plugins=Qt6/plugins
Qml2Imports=Qt6/qml
Documentation=doc/Qt6/
Binaries=bin
LibraryExecutables=tools/Qt6/bin
ArchData=share/Qt6
Data=share/Qt6
Translations=translations/Qt6/
Examples=share/examples/Qt6/
HostPrefix=${CURRENT_HOST_INSTALLED_DIR}
HostData=${CURRENT_INSTALLED_DIR}/share/Qt6
HostBinaries=bin
HostLibraries=lib
HostLibraryExecutables=tools/Qt6/bin
""")

qt_conf("tools/Qt6/qt_debug.conf", "debug/bin/qt.conf", """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Headers=include/Qt6/
Libraries=debug/lib
Plugins=debug/Qt6/plugins
Qml2Imports=debug/Qt6/qml
Documentation=doc/Qt6/
Binaries=debug/bin
LibraryExecutables=tools/Qt6/bin
ArchData=share/Qt6
Data=share/Qt6
Translations=translations/Qt6/
Examples=share/examples/Qt6/
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Headers=include/Qt6/
Libraries=debug/lib
Plugins=debug/Qt6/plugins
Qml2Imports=debug/Qt6/qml
Documentation=doc/Qt6/
Binaries=debug/bin
LibraryExecutables=tools/Qt6/bin
ArchData=share/Qt6
Data=share/Qt6
Translations=translations/Qt6/
Examples=share/examples/Qt6/
HostPrefix=${CURRENT_HOST_INSTALLED_DIR}
HostData=${CURRENT_INSTALLED_DIR}/share/Qt6
HostBinaries=debug/bin
HostLibraries=debug/lib
HostLibraryExecutables=tools/Qt6/bin
""")

is_rpath = False
ensure_link("debug", "include")
is_windows = sys.platform == "win32"
is_linux = not is_windows
# noinspection PyBroadException
try:
    os.environ["PATH"] = "/opt/patchelf/latest/bin:" + os.environ["PATH"]
    is_rpath = is_linux and bool(which("patchelf")) and bool(which("chrpath"))
    if is_rpath and not os.path.exists("bin/runpath2rpath"):
        check_call(["gcc", "-o", "bin/runpath2rpath", "../../runpath2rpath.c"])
except:
    is_rpath = False
exe = "" if is_linux else ".exe"
for t in ("moc", "qmake", "rcc", "uic", "lprodump", "lrelease", "lrelease-pro", "lupdate", "lupdate-pro", "lconvert"):
    ensure_link("bin", f"tools/Qt6/bin/{t}{exe}")
if os.path.exists("tools/protobuf/protoc") and is_linux and os.stat("tools/protobuf/protoc").st_mode & 0o777 != 0o755:
    os.chmod("tools/protobuf/protoc", 0o755)
ensure_link("bin", f"tools/bzip2/bzip2{exe}")
ensure_link("bin", f"tools/liblzma/xz{exe}")
ensure_link("bin", f"tools/grpc/grpc_cpp_plugin{exe}")
ensure_link("bin", f"tools/protobuf/protoc{exe}")
if is_linux:
    glob_rpath()
