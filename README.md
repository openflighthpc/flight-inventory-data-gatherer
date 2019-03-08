# Flight Inventory Data Gatherer

Scripts and binaries for gathering inventory asset data across a HPC cluster for import and use with Flight Inventory.

## Overview

The Flight Inventory Data Gatherer is a collection of statically compiled binaries along with a control script which allows operating-system level data to be collected for a Linux system that can be imported and used by the [Flight Inventory](https://github.com/openflighthpc/flight-inventory) tool.

The data gathered includes:

 * Hardware data (with `lshw`, `dmidecode`, `lspci`, `lscpu`)
 * Disk/storage data (with `fdisk`, `lsblk`, `lsscsi`)
 * Network data (with `ifconfig` and `ip`)
 * Distribution data (with `uname` and `os-release`)

## Installation

### Manual installation

1. Clone the repo.
2. You're done!

### Self-extracting script installation

1. Download the self-extracting script from `build/`.
2. Run the script to extract the required tools.

## Operation

The `src/bin` directory contains static binaries of the system commands used by the gatherer script.

All binaries have been compiled on CentOS 7 and are tested to run on:

- CentOS 6
- CentOS 7
- SLES 11
- Ubuntu 14.04

With this testing in mind, an assumption is made that as the binaries work on these older OSes then they will be portable to later SLES and Ubuntu versions.  Please open an issue if you find a Linux distribution to which they are not portable.

Refer to [BUILD.md](BUILD.md) for build instructions for each of the static binaries.

### Running the gatherer

To run the gatherer, execute the `src/gather-data.sh` script. The binaries are located by looking inside the `bin/` directory found at the same level as the script.

(More details TBC.)

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

## This project

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Inventory Data Gatherer is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.

## Static binaries

Each of the static binaries has been compiled from upstream open-source software and are provided under their own licensing terms.  Licenses can be found for each of the projects as follows:

* `lsblk`, `lscpu` and `fdisk` (from `coreutils`): [coreutils-COPYING.txt](licenses/coreutils-COPYING.txt); see <https://www.gnu.org/software/coreutils/>
* `dmidecode`: [dmidecode-LICENSE.txt](licenses/dmidecode-LICENSE.txt); see <https://www.nongnu.org/dmidecode/>
* `ip` (from `iproute2`): [iproute2-COPYING.txt](licenses/iproute2-COPYING.txt); see <https://wiki.linuxfoundation.org/networking/iproute2>
* `lshw`: [lshw-COPYING.txt](licenses/lshw-COPYING.txt); see <https://github.com/lyonel/lshw>
* `lsscsi`: [lsscsi-COPYING.txt](licenses/lsscsi-COPYING.txt); see <http://sg.danny.cz/scsi/lsscsi.html>
* `ifconfig` (from `net-tools`): [net-tools-COPYING.txt](licenses/net-tools-COPYING.txt); see <http://net-tools.sourceforge.net/>
* `lspci` (from `pciutils`): [pciutils-COPYING.txt](licenses/pciutils-COPYING.txt); see <https://mj.ucw.cz/sw/pciutils/>
* `uname` (from `util-linux`): [util-linux-COPYING.txt](licenses/util-linux-COPYING.txt); see <http://freshmeat.sourceforge.net/projects/util-linux/>
* `zip`: [zip-LICENSE.txt](licenses/zip-LICENSE.txt); <http://infozip.sourceforge.net/Zip.html>
