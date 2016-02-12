#!/bin/sh -xue

VER=$1

if [ -z $VER ]; then
    echo "ERROR: Version is not set. Exiting..."
    exit 1
fi

echo "The latest version so far is " `cat /var/lib/update/image/latest.version`

SWUPDSRVDIR=`dirname $0`/swupd-server

echo "[III] Create basic repo"
$SWUPDSRVDIR/basic_creator.sh $VER
echo "[III] Create full files"
$SWUPDSRVDIR/swupd_make_fullfiles $VER
echo "[III] Create delta pack"
$SWUPDSRVDIR/pack_maker.sh $VER 2
echo "[III] Create zeropack"
/bin/sh -xue $SWUPDSRVDIR/zeropack_maker.sh $VER

echo "[III] Update latest.version"
echo $VER > /var/lib/update/image/latest.version
mkdir -p /var/lib/update/www/version/format3
echo $VER > /var/lib/update/www/version/format3/latest
