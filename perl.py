#!/usr/bin/env python3
import os
import shutil
import sys
import subprocess


def copy_perl():
    p = "../../downloads/tools/perl"
    if os.path.exists("tools/perl") or not os.path.exists(p):
        return
    l = os.listdir(p)
    if not l:
        return
    shutil.copytree(f"{p}/{l[0]}/perl", "tools/perl")



copy_perl()
