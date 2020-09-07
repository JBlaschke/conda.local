#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
import sys
import glob



RUNPATH_TOKEN = "(RUNPATH)"
RPATH_TOKEN   = "(RPATH)"



def read_elf(file_name):
    out = os.popen(f"readelf -d {file_name}").read()

    elf_data = dict()
    elf_data["has_runpath"] = RUNPATH_TOKEN in out
    elf_data["has_rpath"]   = RPATH_TOKEN in out
    elf_data["lines"]       = out.split("\n")
    return elf_data



paren = lambda s: s[s.find("[")+1:s.find("]")]



def get_elf_path(token, lines):
    fi_token = filter(lambda line: token in line, lines)
    matches  = list(fi_token)
    if len(matches) == 1:
        return paren(matches[0])
    else:
        raise RuntimeError(f"Got {len(matches)} matches, expected 1: {matches}")



TRANS_MAP = {"-":r"\-", "]":r"\]", "\\":r"\\", "^":r"\^", "$":r"\$", "*":r"\*"}
escaped = lambda a: a.translate(str.maketrans(TRANS_MAP))



def set_elf_path(rpath, file_name, log="patchelf.log"):
    rpath_escaped = escaped(rpath)
    with open(log, "w") as f:
        f.write(f"")
        f.write(f"* Running patch for {rpath}")

    with open(log, "w") as f:
        f.write(f" 1. patchelf --remove-rpath {file_name}")
    status = os.system(f"patchelf --remove-rpath {file_name}")
    if status != 0 :
        raise RuntimeError(f"patchelf --remove-rpath {file_name} didn't work")

    with open(log, "w") as f:
        f.write(f" 2. patchelf --set-rpath \"{rpath_escaped}\" {file_name}")
    status = os.system(f"patchelf --set-rpath \"{rpath_escaped}\" {file_name}")
    if status != 0 :
        raise RuntimeError(f"patchelf --set-rpath \"{rpath_escaped}\" {file_name}")




if __name__ == "__main__":
    target_dir = sys.argv[1]

    for root, dirs, files in os.walk(target_dir):
        for file_name in glob.glob(os.path.join(root, "*.so")):
            elf = read_elf(file_name)
            if elf["has_rpath"]:
                print(f"Patching {file_name}: RPATH -> RUNPATH")
                rpath = get_elf_path(RPATH_TOKEN, elf["lines"])
                set_elf_path(rpath, file_name)
            else:
                print(f"Not patching {file_name}: no RPATH")
