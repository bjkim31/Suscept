#!/bin/sh

#$ -S /bin/sh
#$ -cwd
#$ -e /dev/null
#$ -o /dev/null

DIR=$1
l=$2
f=$3
LIST=$4

mkdir -p $DIR/knn+snps/l$l/f$f
SIZE=$(wc -l $LIST | awk '{print $1}')

rm ./$DIR/knn+snps/l$l/f$f/snps.bk.list
gawk -v t=$f '{ if (sprintf("%4f",$2) < sprintf("%4f",t/100)) {print $1}}' $DIR/knn+snps/l$l/merged.snps.l$l.tmp > $DIR/knn+snps/l$l/f$f/snps.bk.list 
