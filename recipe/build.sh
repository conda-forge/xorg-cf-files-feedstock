#! /bin/bash

set -e

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

# On Windows we want $LIBRARY_PREFIX in both "mixed" (C:/Conda/...) and Unix
# (/c/Conda) forms, but Unix form is often "/" which can cause problems.
if [ -n "$LIBRARY_PREFIX_M" ] ; then
    mprefix="$LIBRARY_PREFIX_M"
    if [ "$LIBRARY_PREFIX_U" = / ] ; then
        uprefix=""
    else
        uprefix="$LIBRARY_PREFIX_U"
    fi
else
    mprefix="$PREFIX"
    uprefix="$PREFIX"
fi

mkdir builddir
meson setup builddir ${MESON_ARGS} --prefix="$PREFIX" --backend=ninja \
  || { cat builddir/meson-logs/meson-log.txt ; false ; }
ninja -C builddir -j${CPU_COUNT} -v
ninja -C builddir install || { cat builddir/meson-logs/meson-log.txt ; false ; }

rm -rf $uprefix/share/man $uprefix/share/doc/xorg-cf-files
