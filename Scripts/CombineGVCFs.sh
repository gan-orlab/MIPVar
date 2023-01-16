#!/bin/bash

#100 samples -c 1 --mem=4G -t 0:10:0

REF=${REF:-/lustre03/project/6001220/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta}
DICT=$(echo $REF|sed 's/fasta/dict/g')
module load nixpkgs/16.09 gatk/3.8 picard
module load tabix
GVCF_LIST=$1
BED=$2
DIR=$3
RUN=$4


CombineGVCFs_OUT=$DIR/$RUN.g.vcf
SortVcf_OUT=$(echo $CombineGVCFs_OUT|sed 's/g.vcf$/sorted.&.gz/g')

java -Xmx4g -jar $EBROOTGATK/GenomeAnalysisTK.jar -T CombineGVCFs -R $REF $(for i in $(cat $GVCF_LIST); do printf " --variant %s " $i; done) -o $CombineGVCFs_OUT -L $BED --interval_padding 150

mkdir $DIR/tmp_picard_$RUN
java -XX:ParallelGCThreads=2 -Xmx4g -jar $EBROOTPICARD/picard.jar SortVcf I=$CombineGVCFs_OUT O=$SortVcf_OUT SD=$DICT TMP_DIR=$DIR/tmp_picard && tabix -f -p vcf $SortVcf_OUT && rm -rf $CombineGVCFs_OUT $DIR/tmp_picard_$RUN
