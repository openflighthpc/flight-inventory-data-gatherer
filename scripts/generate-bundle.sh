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
TARBALL_NAME="gather-data.tar.gz"
SCRIPT_NAME="gather-data-bundled.sh"
COMMAND_TO_RUN='if [ ! -z $1 ] ; then ./gather-data.sh --name $1 ; else ./gather-data.sh ; fi ; rm -rf ./gather-data.sh ./bin'
root=$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)
source="${root}/src"

if [ $TARBALL_NAME == "" ] ; then
	echo "No suitable tarball name given."
	exit 1
fi

if [ $SCRIPT_NAME == "" ] ; then
	echo "No output filename provided."
	exit 1
fi

if [ -e $source/bin ] && [ -e $source/gather-data.sh ] ; then
	echo "Creating tarball that contains the contents of $source/bin and $source/gather-data.sh..."
	pushd $source > /dev/null 2>&1
	tar -zvcf $root/build/$TARBALL_NAME bin gather-data.sh
	popd > /dev/null 2>&1
else
	echo "Can't find appropriate INVENTORYWARE_ROOT/support/bin directory or gather-data.sh script to tar."
	exit 1
fi

if [ -e $root/scripts/vendor/tartos/tartos.sh ] ; then
	echo "Now creating a self extracting script..."
	pushd $root/build > /dev/null 2>&1
	$root/scripts/vendor/tartos/tartos.sh "$TARBALL_NAME" "$SCRIPT_NAME" "$COMMAND_TO_RUN"
	rm $root/build/$TARBALL_NAME
	echo "Complete - script can now be found at $root/build/$SCRIPT_NAME"
else
	echo "Cannot find 'tartos' script"
	exit 1
fi
