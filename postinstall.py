#!/usr/bin/env python3
import os
import shutil
import sys
import subprocess


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


def ensure_link_full(name, source):
    if not os.path.exists(source):
        return
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
    os.chdir("lib/cmake")
    check_call(["python", "../../../../ports/qt5-base/fixcmake.py"])
    os.chdir(cwd)

qt_conf("tools/qt5/qt_release.conf", "bin/qt.conf",  """[DevicePaths]
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
ensure_links("debug", "include")
ensure_links("share", "lib/cmake")
ensure_links("share/qt5", "doc")
ensure_links("tools/qt5", "mkspecs")
ensure_links("share/qt5/debug", "debug/doc")
ensure_links("tools/qt5/debug", "debug/mkspecs")
ensure_link_full("tools/qt5/bin", "bin")
ensure_link_full("tools/qt5/debug/bin", "debug/bin")
exe = ".exe" if sys.platform == "win32" else ""
for t in ("moc", "qmake", "rcc", "uic"):
    ensure_links("bin", "tools/qt5/bin/" + t + exe)
    ensure_links("debug/bin", "tools/qt5/debug/bin/" + t + exe)
for t in ("h5diff",):
    ensure_links("bin", "tools/hdf5/" + t + exe)
if os.path.exists("tools/protobuf/protoc") and sys.platform != "win32" and not os.access("tools/protobuf/protoc", os.X_OK):
    os.chmod("tools/protobuf/protoc", 0o744)
ensure_link("bin", "tools/protobuf/protoc" + exe)
