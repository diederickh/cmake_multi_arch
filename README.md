# USING CMAKE_SYSTEM_PROCESSOR

I created this repository to experiment with the
CMAKE_SYSTEM_PROCESSOR to link with different libraries based on the
architecture. Somehow the CMAKE_SYSTEM_PROCESSOR that I define in my
toolchain files is overwritten. Using a cached variable doesn't seem
to make a difference.

## Reproduce the issue


    git clone git@github.com:roxlu/cmake_multi_arch.git
    cd cmake_multi_arch
    cd build
    ./release.sh
    
