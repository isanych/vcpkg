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


def check_call(args):
    print(" ".join(p if " " not in p else "'" + p + "'" for p in args), flush=True)
    subprocess.check_call(args)


def get_rpath(file):
    try:
        s = get_output(["chrpath", file]).split()
        if len(s) == 2:
            return s[1]
    except subprocess.CalledProcessError:
        pass
    return ""


def set_rpath(file):
    if not is_elf(file):
        return
    if os.path.islink(file):
        file = os.path.realpath(file)
    file = os.path.relpath(file)
    parts = file.split("/")
    origin = f"$ORIGIN/{'/'.join(['..'] * (len(parts) - 1))}"
    current = get_rpath(file)
    if current == f"RPATH={origin}":
        return
    check_call(["patchelf", "--set-rpath", origin, file])
    check_call(["runpath2rpath", file])


for (dirpath, dirnames, filenames) in os.walk("."):
    for file in filenames:
        set_rpath(os.path.join(dirpath, file))
