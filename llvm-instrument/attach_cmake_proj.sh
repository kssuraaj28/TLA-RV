#!/usr/bin/env bash
#   This is a script that is meant to be sourced whenever you want to integrate with an existing cmake project.
#   It will pass clang14 as the compiler, and pass the appropriate flags

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

clang_bin_rt=${clang_bin:-"/usr/lib/llvm14/bin/"}
pass_path=${pass_path:-"$script_dir/llvm-pass/build/libllvm-pass.so"}
pass_path_abs=$(realpath $pass_path)
rtlib_dir=${rtlib:-"$script_dir/rtlib/build/"}
rtlib_abs=$(realpath $rtlib_dir)
rtlib_name=${rtlib_name:-logger}

(
    cd $script_dir/rtlib/build/ && make
    cd $script_dir/llvm-pass/build && make
)

export CC="$clang_bin_rt/clang"
export CXX="$clang_bin_rt/clang++"
#You can add -v here if you want debug info
export CFLAGS="-v -flegacy-pass-manager -Xclang -load -Xclang $pass_path_abs"
export CXXFLAGS="-v -flegacy-pass-manager -Xclang -load -Xclang $pass_path_abs"
export LDFLAGS="-Wl,-rpath=$rtlib_dir -L$rtlib_dir -l$rtlib_name"
