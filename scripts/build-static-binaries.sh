#!/bin/bash
#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Inventory Data Gatherer.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Inventory Data Gatherer is distributed in the hope that it
# will be useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# EITHER EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY
# WARRANTIES OR CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY
# OR FITNESS FOR A PARTICULAR PURPOSE. See the Eclipse Public License
# 2.0 for more details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Inventory Data Gatherer. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Inventory Data Gatherer , please
# visit:
# https://github.com/openflighthpc/flight-inventory-data-gatherer
#===============================================================================
set -e
set -x

mkdir -p /tmp/build/dist

### dmicode

cd /tmp/build
wget http://ftp.igh.cnrs.fr/pub/nongnu/dmidecode/dmidecode-3.2.tar.xz
tar xJf dmidecode-3.2.tar.xz
cd dmidecode-3.2
export VERBOSE=1
make
# GCC command from the above make
gcc -static -W -Wall -Wshadow -Wstrict-prototypes -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wmissing-prototypes -Winline -Wundef -D_FILE_OFFSET_BITS=64 -O2 -c dmidecode.c -o dmidecode.o
gcc -static dmidecode.o dmiopt.o dmioem.o util.o -o dmidecode
cp dmidecode /tmp/build/dist

### ifconfig

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
cp ifconfig /tmp/build/dist

### ip

cd /tmp/build
wget https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.19.0.tar.xz
tar xJf iproute2-4.19.0.tar.xz
yum install libselinux-static flex
cd iproute2-4.19.0
make LDFLAGS=-static
cp ip/ip /tmp/build/dist

### util-linux (lsblk, lscpu, fdisk)

yum -y -e0 groupinstall "Development Tools"
yum -y -e0 install ncurses-static readline-static
cd /tmp/build
git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git
cd util-linux
git checkout v2.33.1
./autogen.sh

# Configure and build static libraries for creating the binaries
./configure --enable-static --enable-static-programs='fdisk,blkid'
make || true
gcc -std=gnu99 -DHAVE_CONFIG_H -I.  -include config.h -I./include -DLOCALEDIR=\"/tmp/build/libblkidtest/share/locale\" -D_PATH_RUNSTATEDIR=\"/tmp/build/libblkidtest/var/run\"  -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -MT misc-utils/lsblk-lsblk.o -MD -MP -MF misc-utils/.deps/lsblk-lsblk.Tpo -c -o misc-utils/lsblk-lsblk.o `test -f 'misc-utils/lsblk.c' || echo './'`misc-utils/lsblk.c
gcc -static -o .libs/lsblk  misc-utils/lsblk-lsblk.o misc-utils/lsblk-lsblk-properties.o misc-utils/lsblk-lsblk-mnt.o ./.libs/libmount.a  ./.libs/libblkid.a ./.libs/libuuid.a ./.libs/libsmartcols.a
gcc -static -o .libs/lscpu sys-utils/lscpu-lscpu.o sys-utils/lscpu-lscpu-arm.o sys-utils/lscpu-lscpu-dmi.o  ./.libs/libcommon.a ./.libs/libsmartcols.a
gcc -static -o fdisk disk-utils/fdisk-fdisk.o disk-utils/fdisk-fdisk-menu.o disk-utils/fdisk-fdisk-list.o  .libs/libcommon.a .libs/libfdisk.a .libs/libsmartcols.a .libs/libtcolors.a .libs/libblkid.a .libs/libuuid.a -lreadline -ltinfo
cp .libs/lsblk .libs/lscpu fdisk /tmp/build/dist

### lshw

yum -y -e0 groupinstall "Development Tools"
yum -y -e0 install upx compat-glibc glibc-static libstdc++-static
cd /tmp/build
git clone https://github.com/lyonel/lshw
cd lshw/src
make static
cp lshw-static /tmp/build/dist

### pciutils

yum -y -e0 groupinstall "Development Tools"
yum -y -e0 install zlib-static
cd /tmp/build
git clone https://github.com/gittup/pciutils
cd pciutils
make CC="gcc -static"
cp lspci /tmp/build/dist

### lsscsi

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
cp lsscsi /tmp/build/dist

### uname

yum -y -e0 install glibc-static
cd /tmp/build
wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.30.tar.xz
tar xJf coreutils-8.30.tar.xz
cd coreutils-8.30
export FORCE_UNSAFE_CONFIGURE=1
./configure
make
gcc -static -std=gnu11  -I. -I./lib  -Ilib -I./lib -Isrc -I./src   -fno-common -W -Waddress -Waggressive-loop-optimizations -Wall -Wattributes -Wbad-function-cast -Wbuiltin-macro-redefined -Wcast-align -Wchar-subscripts -Wclobbered -Wcomment -Wcomments -Wcoverage-mismatch -Wcpp -Wdeprecated -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wdouble-promotion -Wempty-body -Wendif-labels -Wenum-compare -Wextra -Wformat-contains-nul -Wformat-extra-args -Wformat-security -Wformat-y2k -Wformat-zero-length -Wfree-nonheap-object -Wignored-qualifiers -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Winit-self -Wint-to-pointer-cast -Winvalid-memory-model -Winvalid-pch -Wmain -Wmaybe-uninitialized -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-include-dirs -Wmissing-parameter-type -Wmissing-prototypes -Wmultichar -Wnarrowing -Wnonnull -Wold-style-declaration -Wold-style-definition -Woverflow -Woverlength-strings -Woverride-init -Wpacked -Wpacked-bitfield-compat -Wparentheses -Wpointer-arith -Wpointer-sign -Wpointer-to-int-cast -Wpragmas -Wpsabi -Wreturn-local-addr -Wreturn-type -Wsequence-point -Wshadow -Wsizeof-pointer-memaccess -Wstrict-aliasing -Wstrict-overflow -Wstrict-prototypes -Wsuggest-attribute=const -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wswitch -Wsync-nand -Wtrampolines -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-local-typedefs -Wunused-macros -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wvarargs -Wvariadic-macros -Wvector-operation-performance -Wvolatile-register-var -Wwrite-strings -Wnormalized=nfc -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-format-nonliteral -Wlogical-op -fdiagnostics-show-option -funit-at-a-time -g -O2 -MT src/uname.o -MD -MP -MF $depbase.Tpo -c -o src/uname.o src/uname.c
gcc -static -std=gnu11  -fno-common -W -Waddress -Waggressive-loop-optimizations -Wall -Wattributes -Wbad-function-cast -Wbuiltin-macro-redefined -Wcast-align -Wchar-subscripts -Wclobbered -Wcomment -Wcomments -Wcoverage-mismatch -Wcpp -Wdeprecated -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wdouble-promotion -Wempty-body -Wendif-labels -Wenum-compare -Wextra -Wformat-contains-nul -Wformat-extra-args -Wformat-security -Wformat-y2k -Wformat-zero-length -Wfree-nonheap-object -Wignored-qualifiers -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Winit-self -Wint-to-pointer-cast -Winvalid-memory-model -Winvalid-pch -Wmain -Wmaybe-uninitialized -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-include-dirs -Wmissing-parameter-type -Wmissing-prototypes -Wmultichar -Wnarrowing -Wnonnull -Wold-style-declaration -Wold-style-definition -Woverflow -Woverlength-strings -Woverride-init -Wpacked -Wpacked-bitfield-compat -Wparentheses -Wpointer-arith -Wpointer-sign -Wpointer-to-int-cast -Wpragmas -Wpsabi -Wreturn-local-addr -Wreturn-type -Wsequence-point -Wshadow -Wsizeof-pointer-memaccess -Wstrict-aliasing -Wstrict-overflow -Wstrict-prototypes -Wsuggest-attribute=const -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wswitch -Wsync-nand -Wtrampolines -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-function -Wunused-label -Wunused-local-typedefs -Wunused-macros -Wunused-parameter -Wunused-result -Wunused-value -Wunused-variable -Wvarargs -Wvariadic-macros -Wvector-operation-performance -Wvolatile-register-var -Wwrite-strings -Wnormalized=nfc -Wno-sign-compare -Wno-type-limits -Wno-unused-parameter -Wno-format-nonliteral -Wlogical-op -fdiagnostics-show-option -funit-at-a-time -g -O2 -Wl,--as-needed  -o src/uname src/uname.o src/uname-uname.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a
cp src/uname /tmp/build/dist

### zip

cd /tmp/build
git clone https://github.com/LuaDist/zip
cd zip
git checkout 3.0
make -f unix/Makefile generic CC='gcc -static'
cp zip /tmp/build/dist

### strip the binaries

cd /tmp/build/dist
strip *
