#!/bin/bash

if [ -z "$1" ]
then
  echo "path necessary"
  exit 1
fi

pa=$1
pushd $pa > /dev/null
pi=`ls $pa/*.webp`

for picture in $pi
do
DELAY=${DELAY:-10}
LOOP=${LOOP:-0}
r=`realpath $picture`
d=`dirname $r`
pushd $d > /dev/null
f=`basename $r`
an=`echo $(grep -c "ANMF" $f)`

if (( $an > 0 ))
then
n=`webpinfo -summary $f | grep frames | sed -e 's/.* \([0-9]*\)$/\1/'`
dur=`webpinfo -summary $f | grep Duration | head -1 |  sed -e 's/.* \([0-9]*\)$/\1/'`

if (( $dur > 0 )); then
    DELAY=$dur
fi

pfx=`echo -n $f | sed -e 's/^\(.*\).webp$/\1/'`
if [ -z $pfx ]; then
    pfx=$f
fi

echo "converting $n frames from $f
working dir $d
file stem '$pfx'"

for i in $(seq -f "%05g" 1 $n)
do
    webpmux -get frame $i $f -o $pfx.$i.webp &>/dev/null
    dwebp $pfx.$i.webp -o $pfx.$i.png &>/dev/null
done

convert $pfx.*.png -delay $DELAY -loop $LOOP $pfx.gif
rm $pfx.[0-9]*.png $pfx.[0-9]*.webp
if [ $? -eq 0 ]
then
  echo "Successfully created file"
  rm $pfx.webp
fi
popd > /dev/null
else
    echo "file is a picture"
    pfx=`echo -n $f | sed -e 's/^\(.*\).webp$/\1/'`
    if [ -z $pfx ]; then
        pfx=$f
    fi
    dwebp $pfx.webp -o $pfx.png
    if [ $? -eq 0 ]
    then
      echo "Successfully created file"
      rm $pfx.webp
    fi
    popd > /dev/null
fi
done
