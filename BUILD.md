# Build instructions for static binaries

The following instructions allow the binaries required for inventory asset data gathering to be built from their source as **static binaries**.  This allows them to be use without requiring installation of any library infrastructure and across multiple Linux distributions.

All static binaries are currently built under an Enterprise Linux 7 distribution, e.g. CentOS 7.

The instructions below assume they are being built in a build area at `/tmp/build`.

You can build all the binaries in one go using `scripts/build-static-binaries.sh`.

## `dmidecode`

### Instructions

```
cd /tmp/build
wget http://ftp.igh.cnrs.fr/pub/nongnu/dmidecode/dmidecode-3.2.tar.xz
cd dmidecode-3.2
export VERBOSE=1
make
# GCC command from the above make
gcc -static -W -Wall -Wshadow -Wstrict-prototypes -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wmissing-prototypes -Winline -Wundef -D_FILE_OFFSET_BITS=64 -O2 -c dmidecode.c -o dmidecode.o
gcc -static dmidecode.o dmiopt.o dmioem.o util.o -o dmidecode
```

Binary is available at `./dmidecode`

## `ifconfig`

### Instructions

```
cd /tmp/build
wget http://deb.debian.org/debian/pool/main/n/net-tools/net-tools_1.60+git20161116.90da8a0.orig.tar.gz
wget http://deb.debian.org/debian/pool/main/n/net-tools/net-tools_1.60+git20161116.90da8a0-1.debian.tar.xz
tar xzf net-tools_1.60+git20161116.90da8a0.orig.tar.gz
cd net-tools-1.60+git20161116.90da8a0
tar xJf ../net-tools_1.60+git20161116.90da8a0-1.debian.tar.xz
rm -f debian/patches/Bug#632660-netstat.c-long_udp6_addr.patch debian/patches/series
for a in debian/patches/*; do echo "== $a"; patch -p1 < $a; done
yes '' | make ifconfig
cc -static -O2 -g -Wall -fno-strict-aliasing  -Llib -o ifconfig ifconfig.o -lnet-tools
```

Binary is available at `./ifconfig`

## `ip`

### Instructions

```
cd /tmp/build
wget https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.19.0.tar.xz
tar xJf iproute2-4.19.0.tar.xz
yum install libselinux-static flex
cd iproute2-4.19.0
make LDFLAGS=-static
```

Binary is available at `ip/ip`.

## `lsblk`, `lscpu`, `fdisk`

### Instructions

- Util Linux configuration

  ```
  yum groupinstall "Development Tools"
  yum install ncurses-static readline-static
  cd /tmp/build
  git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git
  cd util-linux
  git checkout v2.33.1
  ./autogen.sh

  # Configure and build static libraries for creating the binaries
  ./configure --enable-static --enable-static-programs='fdisk,blkid'

  make || true
  ```

- Manually compile `lsblk `

  ```
  gcc -std=gnu99 -DHAVE_CONFIG_H -I.  -include config.h -I./include -DLOCALEDIR=\"/tmp/build/libblkidtest/share/locale\" -D_PATH_RUNSTATEDIR=\"/tmp/build/libblkidtest/var/run\"  -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -MT misc-utils/lsblk-lsblk.o -MD -MP -MF misc-utils/.deps/lsblk-lsblk.Tpo -c -o misc-utils/lsblk-lsblk.o `test -f 'misc-utils/lsblk.c' || echo './'`misc-utils/lsblk.c
  gcc -static -o .libs/lsblk  misc-utils/lsblk-lsblk.o misc-utils/lsblk-lsblk-properties.o misc-utils/lsblk-lsblk-mnt.o ./.libs/libmount.a  ./.libs/libblkid.a ./.libs/libuuid.a ./.libs/libsmartcols.a
  ```
  
  The binary is available at `.libs/lsblk`.

- Manually compile `lscpu`

  ```
  gcc -static -o .libs/lscpu sys-utils/lscpu-lscpu.o sys-utils/lscpu-lscpu-arm.o sys-utils/lscpu-lscpu-dmi.o  ./.libs/libcommon.a ./.libs/libsmartcols.a
  ```
  
  The binary is available at `.libs/lscpu`.

- Manually compile `fdisk`

  ```
  gcc -static -o fdisk disk-utils/fdisk-fdisk.o disk-utils/fdisk-fdisk-menu.o disk-utils/fdisk-fdisk-list.o  .libs/libcommon.a .libs/libfdisk.a .libs/libsmartcols.a .libs/libtcolors.a .libs/libblkid.a .libs/libuuid.a -lreadline -ltinfo
  ```
  
  The binary is available at `./fdisk`.

## `lshw`

### Instructions

```
yum groupinstall "Development Tools"
yum install upx compat-glibc glibc-static libstdc++-static
cd /tmp/build
git clone https://github.com/lyonel/lshw
cd lshw/src
make static
```

The binary is available at `./lshw-static`.

## `lspci`

### Instructions

```
yum groupinstall "Development Tools"
yum install zlib-static
cd /tmp/build
git clone https://github.com/gittup/pciutils
cd pciutils
make CC="gcc -static"
```

The binary is available at `./lscpi`.

## `lsscsi`

### Instructions

```
cd /tmp/build
git clone https://github.com/hreinecke/lsscsi
cd lsscsi
git checkout v0.28
./configure
export VERBOSE=1
make
# GCC line copied from make output
cd src
gcc -static -DHAVE_CONFIG_H -I. -I..    -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -W -g -O2 -MT lsscsi.o -MD -MP -MF .deps/lsscsi.Tpo -c -o lsscsi.o lsscsi.c
gcc -static -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -W -g -O2   -o lsscsi lsscsi.o
```

Binary is available at `./lsscsi`.

## `uname`

### Instructions

```
yum install glibc-static
wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.30.tar.xz
tar xJf coreutils-8.30.tar.xz
cd coreutils-8.30
./configure
make
gcc -static -std=gnu11  -I. -I./lib  -Ilib -I./lib -Isrc -I./src   -fno-common -W -Waddress -Waggressive-loop-optimizations -Wall -Wattributes -Wbad-function-cast -Wbuiltin-macro-redefined -Wcast-align -Wchar-subscripts -Wclobbered -Wcomment -Wcomments -Wcoverage-mismatch -Wcpp -Wdeprecated -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wdouble-promotion -Wempty-body -Wendif-labels -Wenum-compare -Wextra -Wformat-contains-nul -Wformat-extra-args -Wformat-security -Wformat-y2k -Wformat-zero-length -Wfree-nonheap-object -Wignored-qualifiers -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Winit-self -Wint-to-pointer-cast -Winvalid-memory-model -Winvalid-pch -Wmain -Wmaybe-uninitialized -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-include-dirs -Wmissing-parameter-type -Wmissing-prototypes -Wmultichar -Wnarrowing -Wnonnull -Wold-style-declaration -Wold-style-definition -Woverflow -Woverlength-strings -Woverride-init -Wpacked -Wpacked-bitfield-compat -Wparentheses -Wpointer-arith -Wpointer-sign -Wpointer-to-int-cast -Wpragmas -Wpsabi -Wreturn-local-addr -Wreturn-type -Wsequence-point -Wshadow -Wsizeof-pointer-memaccess -Wstrict-aliasing -Wstrict-overflow -Wstrict-prototypes -Wsuggest-attribute=const -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wswitch -Wsync-nand -Wtrampolines -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-local-typedefs -Wunused-macros -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wvarargs -Wvariadic-macros -Wvector-operation-performance -Wvolatile-register-var -Wwrite-strings -Wnormalized=nfc -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-format-nonliteral -Wlogical-op -fdiagnostics-show-option -funit-at-a-time -g -O2 -MT src/uname.o -MD -MP -MF $depbase.Tpo -c -o src/uname.o src/uname.c
gcc -static -std=gnu11  -fno-common -W -Waddress -Waggressive-loop-optimizations -Wall -Wattributes -Wbad-function-cast -Wbuiltin-macro-redefined -Wcast-align -Wchar-subscripts -Wclobbered -Wcomment -Wcomments -Wcoverage-mismatch -Wcpp -Wdeprecated -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wdouble-promotion -Wempty-body -Wendif-labels -Wenum-compare -Wextra -Wformat-contains-nul -Wformat-extra-args -Wformat-security -Wformat-y2k -Wformat-zero-length -Wfree-nonheap-object -Wignored-qualifiers -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Winit-self -Wint-to-pointer-cast -Winvalid-memory-model -Winvalid-pch -Wmain -Wmaybe-uninitialized -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-include-dirs -Wmissing-parameter-type -Wmissing-prototypes -Wmultichar -Wnarrowing -Wnonnull -Wold-style-declaration -Wold-style-definition -Woverflow -Woverlength-strings -Woverride-init -Wpacked -Wpacked-bitfield-compat -Wparentheses -Wpointer-arith -Wpointer-sign -Wpointer-to-int-cast -Wpragmas -Wpsabi -Wreturn-local-addr -Wreturn-type -Wsequence-point -Wshadow -Wsizeof-pointer-memaccess -Wstrict-aliasing -Wstrict-overflow -Wstrict-prototypes -Wsuggest-attribute=const -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wswitch -Wsync-nand -Wtrampolines -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-local-typedefs -Wunused-macros -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wvarargs -Wvariadic-macros -Wvector-operation-performance -Wvolatile-register-var -Wwrite-strings -Wnormalized=nfc -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-format-nonliteral -Wlogical-op -fdiagnostics-show-option -funit-at-a-time -g -O2 -Wl,--as-needed  -o src/uname src/uname.o src/uname-uname.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a
```

Binary is available at `./src/uname`.

## `zip`

### Instructions

```
cd /tmp/build
git clone https://github.com/LuaDist/zip
cd zip
git checkout 3.0
make -f unix/Makefile generic CC='gcc -static'
```

Binary is available at `./zip`.
