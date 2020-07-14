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
    dir = os.path.dirname(name)
    if dir and not os.path.exists(dir):
        os.makedirs(dir)
    return dir


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
    if os.path.islink(file):
        file = os.path.realpath(file)
        file = os.path.relpath(file)
    parts = file.split("/")
    is_debug = len(parts) > 2 and parts[-3] == "debug"
    origin = f"$ORIGIN/{'/'.join(['..'] * (len(parts) - 1))}{'/debug' if is_debug else ''}/lib"
    current = get_rpath(file)
    if current == f"RPATH={origin}":
        return
    check_call(["patchelf", "--set-rpath", origin, file])
    check_call(["bin/runpath2rpath", file])


def ensure_link_full(name, source):
    if not os.path.exists(source):
        return
    set_rpath(source)
    if os.path.isfile(name) and os.stat(name).st_size == 0:
        os.remove(name)
    if os.path.exists(name):
        return
    dir = ensure_dir(name)
    rel_source = os.path.relpath(source, dir)
    os.symlink(rel_source, name, target_is_directory=os.path.isdir(source))


def ensure_link(dir, source):
    ensure_link_full(os.path.join(dir, os.path.basename(source)), source)


def ensure_links(dir, source):
    ensure_link(dir, source)
    ensure_link(os.path.dirname(source), os.path.join(dir, os.path.basename(source)))


def ensure_file(name, data):
    if not os.path.exists(name):
        write_file(name, data)


def qt_conf_one(name, content):
    if os.path.exists(name):
        content = read_file(name)
    if "${CURRENT_INSTALLED_DIR}" in content:
        write_file(name, content.replace("${CURRENT_INSTALLED_DIR}", cwd.replace("\\", "/")))
    return content


def qt_conf(f1, f2, content):
    content = qt_conf_one(f1, content)
    qt_conf_one(f2, content)


cwd = os.getcwd()
if os.path.exists("debug/lib/cmake"):
    shutil.rmtree("debug/lib/cmake")

qt_conf("tools/qt5/qt_release.conf", "bin/qt.conf", """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/doc
LibraryExecutables=tools/qt5
Imports=tools/qt5/imports
ArchData=tools/qt5
Data=share/qt5
Translations=share/qt5/translations
Examples=share/qt5/examples
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/doc
LibraryExecutables=tools/qt5
Imports=tools/qt5/imports
ArchData=tools/qt5
Data=share/qt5
Translations=share/qt5/translations
Examples=share/qt5/examples
HostPrefix=${CURRENT_INSTALLED_DIR}/tools/qt5
TargetSpec=win32-msvc
HostSpec=win32-msvc
""" if sys.platform == "win32" else """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/doc
LibraryExecutables=tools/qt5
Imports=tools/qt5/imports
ArchData=tools/qt5
Data=share/qt5
Translations=share/qt5/translations
Examples=share/qt5/examples
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/doc
LibraryExecutables=tools/qt5
Imports=tools/qt5/imports
ArchData=tools/qt5
Data=share/qt5
Translations=share/qt5/translations
Examples=share/qt5/examples
HostPrefix=${CURRENT_INSTALLED_DIR}/tools/qt5
TargetSpec=linux-g++
HostSpec=linux-g++
""")

qt_conf("tools/qt5/qt_debug.conf", "debug/bin/qt.conf", """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/debug/doc
Libraries=debug/lib
LibraryExecutables=tools/qt5/debug
Binaries=debug/bin
Plugins=debug/plugins
Imports=tools/qt5/debug/imports
Qml2Imports=debug/qml
ArchData=tools/qt5/debug
Data=share/qt5/debug
Translations=share/qt5/debug/translations
Examples=share/qt5/debug/examples
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/debug/doc
Libraries=debug/lib
LibraryExecutables=tools/qt5/debug
Binaries=debug/bin
Plugins=debug/plugins
Imports=tools/qt5/debug/imports
Qml2Imports=debug/qml
ArchData=tools/qt5/debug
Data=share/qt5/debug
Translations=share/qt5/debug/translations
Examples=share/qt5/debug/examples
HostPrefix=${CURRENT_INSTALLED_DIR}/tools/qt5/debug
TargetSpec=win32-msvc
HostSpec=win32-msvc
""" if sys.platform == "win32" else """[DevicePaths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/debug/doc
Libraries=debug/lib
LibraryExecutables=tools/qt5/debug
Binaries=debug/bin
Plugins=debug/plugins
Imports=tools/qt5/debug/imports
Qml2Imports=debug/qml
ArchData=tools/qt5/debug
Data=share/qt5/debug
Translations=share/qt5/debug/translations
Examples=share/qt5/debug/examples
[Paths]
Prefix=${CURRENT_INSTALLED_DIR}
Documentation=share/qt5/debug/doc
Libraries=debug/lib
LibraryExecutables=tools/qt5/debug
Binaries=debug/bin
Plugins=debug/plugins
Imports=tools/qt5/debug/imports
Qml2Imports=debug/qml
ArchData=tools/qt5/debug
Data=share/qt5/debug
Translations=share/qt5/debug/translations
Examples=share/qt5/debug/examples
HostPrefix=${CURRENT_INSTALLED_DIR}/tools/qt5/debug
TargetSpec=linux-g++
HostSpec=linux-g++
""")

ensure_file("share/qt5core/vcpkg-cmake-wrapper.cmake", """_find_package(${ARGS})

function(add_qt_library _target)
    foreach(_lib IN LISTS ARGN)
        find_library(${_lib}_LIBRARY_DEBUG NAMES ${_lib}d PATH_SUFFIXES debug/plugins/platforms)
        find_library(${_lib}_LIBRARY_RELEASE NAMES ${_lib} PATH_SUFFIXES plugins/platforms)
        set_property(TARGET ${_target} APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        \$<\$<NOT:\$<CONFIG:DEBUG>>:${${_lib}_LIBRARY_RELEASE}>\$<\$<CONFIG:DEBUG>:${${_lib}_LIBRARY_DEBUG}>)
    endforeach()
endfunction()
""")
is_rpath = False
ensure_links("debug", "include")
ensure_links("share", "lib/cmake")
ensure_links("share/qt5", "doc")
ensure_links("tools/qt5", "mkspecs")
ensure_links("share/qt5/debug", "debug/doc")
ensure_links("tools/qt5/debug", "debug/mkspecs")
ensure_link_full("tools/qt5/bin", "bin")
ensure_link_full("tools/qt5/debug/bin", "debug/bin")
is_linux = sys.platform != "win32"
try:
    is_rpath = is_linux and bool(which("patchelf")) and bool(which("chrpath"))
    if is_rpath and not os.path.exists("bin/runpath2rpath"):
        check_call(["gcc", "-o", "bin/runpath2rpath", "../../runpath2rpath.c"])
except:
    is_rpath = False
exe = "" if is_linux else ".exe"
for t in ("moc", "qmake", "rcc", "uic"):
    ensure_links("bin", f"tools/qt5/bin/{t}{exe}")
    ensure_links("debug/bin", f"tools/qt5/debug/bin/{t}{exe}")
for t in ("h5diff", "h5dump"):
    ensure_link_full(f"bin/{t}{exe}", f"tools/hdf5/{t}-shared{exe}")
if os.path.exists("tools/protobuf/protoc") and is_linux and os.stat("tools/protobuf/protoc").st_mode & 0o777 != 0o755:
    os.chmod("tools/protobuf/protoc", 0o755)
ensure_link("bin", f"tools/protobuf/protoc{exe}")
ensure_link("bin", f"tools/grpc/grpc_cpp_plugin{exe}")
