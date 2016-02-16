#!/bin/sh -xe

VER=$1

if [ -z "${VER}" ]; then
    echo "ERROR: Version is not set. Exiting..."
    exit 1
fi

UPDATEDIR="/var/lib/update"

mkdir -p ${UPDATEDIR}/image
mkdir -p ${UPDATEDIR}/log
touch ${UPDATEDIR}/image/latest.version
echo "The latest version so far is " `cat ${UPDATEDIR}/image/latest.version`

SWUPDSRVDIR=`dirname $0`/swupd-server
SWUPDSRVDIR=`realpath $SWUPDSRVDIR`

cd ${UPDATEDIR}/log

echo "[III] Refresh server.ini"
cp $SWUPDSRVDIR/server.ini /var/lib/update/server.ini

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
