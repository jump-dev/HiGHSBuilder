# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "highs"
version = v"0.1.0"

# Collection of sources required to build highs
sources = [
    "https://github.com/ERGO-Code/HiGHS.git" =>
    "989fa8ed33220badc04ca4dc22e14e59be2c4b09",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd HiGHS/
mkdir build
cd build
LDFLAGS="-Wl,-rpath-link,/opt/${target}/${target}/lib -Wl,-rpath-link,/opt/${target}/${target}/lib64" $LDFLAGS
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain ..
make
make install
exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_gcc_versions([
    Linux(:x86_64, libc=:glibc),
    Windows(:x86_64),
])

setdiff!(platforms, [Windows(:x86_64, compiler_abi=CompilerABI(:gcc4)), Windows(:x86_64, compiler_abi=CompilerABI(:gcc7))])

# The products that we will ensure are always built
products(prefix) = [LibraryProduct(prefix, "libhighs", :libhighs)]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
