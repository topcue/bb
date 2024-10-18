#!/bin/bash

if [ -z "$DIFFOPTMZ_ROOT" ]; then
    echo "env \$DIFFOPTMZ_ROOT should be defined first."
    echo "source scripts/env.sh"
    exit
fi

TOOL_PATH="$DIFFOPTMZ_ROOT/dep/tools/"

declare -a archlist=(
    "i686-ubuntu-linux-gnu"
    "x86_64-ubuntu-linux-gnu"
    "arm-ubuntu-linux-gnueabi"
    "aarch64-ubuntu-linux-gnu"
    "mipsel-ubuntu-linux-gnu"
    "mips64el-ubuntu-linux-gnu"
)

declare -a slavelist=(
    "addr2line"
    "ar"
    "as"
    "c++"
    "cc"
    "c++filt"
    "cpp"
    "ct-ng.config"
    "elfedit"
    "g++"
    "gcc-8.2.0"
    "gcc-ar"
    "gcc-nm"
    "gcc-ranlib"
    "gcov"
    "gcov-dump"
    "gcov-tool"
    "gprof"
    "ld"
    "ld.bfd"
    "ldd"
    "nm"
    "objcopy"
    "objdump"
    "populate"
    "ranlib"
    "readelf"
    "size"
    "strings"
    "strip"
)

COMPVER="8.2.0"

for ARCH_PREFIX in "${archlist[@]}"; do
    TOOLCHAIN_PATH="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/bin/${ARCH_PREFIX}"
    SYSROOT="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/${ARCH_PREFIX}/sysroot"

    echo "${ARCH_PREFIX}"
    CMD="sudo update-alternatives --force --install /usr/bin/${ARCH_PREFIX}-gcc \
    ${ARCH_PREFIX}-gcc ${TOOLCHAIN_PATH}-gcc 100"

    for slave in "${slavelist[@]}"; do
        CMD="${CMD} --slave /usr/bin/${ARCH_PREFIX}-${slave} \
    ${ARCH_PREFIX}-${slave} \
    ${TOOLCHAIN_PATH}-${slave}"
    done
    eval "$CMD"

    # give write permission to set symbolic link
    chmod ug+w -R "${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}"

    # some compilation environment do not search sysroot.
    CWD=$(pwd)
    cd "${SYSROOT}/../lib"
    ln -sf ../sysroot/lib/* ./
    ln -sf ../sysroot/usr/lib/* ./
    cd $CWD

    # powerpc-ubuntu-linux-gnu-ld looks for lib32 first and fails
    if [[ ${ARCH_PREFIX} == "powerpc-ubuntu-linux-gnu" ]]; then
	LIB32_DIR="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/${ARCH_PREFIX}/lib32"
        mkdir -p "${LIB32_DIR}"
	pushd "${LIB32_DIR}" >/dev/null
	ln -sf ../sysroot/lib/* ./
        ln -sf ../sysroot/usr/lib/* ./
	popd >/dev/null
    fi
done

# EOF
