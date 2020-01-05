#!/bin/bash

read BASE_DIR gene cohort_name DP core <<< $@
if [[ ! -s $BASE_DIR ]]; then echo "ERROR: input base directory (1st argument) not specified, empty or does not exist"; exit 42; fi
if [[ -z $gene ]]; then echo "ERROR: gene (2st arg) not specified"; exit 42; fi
if [[ -z $DP || ! $DP -gt 0 ]]; then echo "ERROR: depth (4nd arg) not specified"; exit 42; fi
if [[ -z $cohort_name ]]; then echo "ERROR: cohort name (3rd arg) not specified"; exit 42; fi
if [[ -z $core || ! $core -gt 0 ]]; then echo "ERROR: depth (5nd arg) not specified"; exit 42; fi

REF=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta
GATK37=~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar

#INTERVALS=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}.final.intervals
INTERVALS=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}_geno10_ind10_hwe_testmiss.vcf
SAMPLE_LIST=$BASE_DIR/$gene/$cohort_name/${DP}x/${gene}_${cohort_name}_DP${DP}.geno10.indvtoremove
vcf=$BASE_DIR/$gene/$cohort_name/${DP}x/$gene.$cohort_name.DP$DP.vcf
NO_SAMPLE=0
if [[ ! -s $INTERVALS ]]; then echo "ERROR: intervals list $INTERVALS empty or does not exist"; exit 42; fi
if [[ ! -s $SAMPLE_LIST ]]; then echo "ERROR: sample list $SAMPLE_LIST empty or does not exist"; NO_SAMPLE=1; fi
if [[ ! -s $vcf ]]; then echo "ERROR: input vcf empty or does not exist; name should be $vcf"; exit 42; fi

temp=$BASE_DIR/$gene/$cohort_name/${DP}x/analysis/$gene.$cohort_name.DP$DP.temp.vcf
output=$BASE_DIR/$gene/$cohort_name/${DP}x/analysis/$gene.$cohort_name.DP$DP.final.vcf

java -Xmx4g -jar $GATK37 -T SelectVariants -R $REF -V $vcf -o $temp -L $INTERVALS -env -nt $core 

cp $temp $output

if [[ NO_SAMPLE -eq 0 ]] 
    then awk -v sample=$(cut -d ' ' -f 1 $SAMPLE_LIST | sed -z 's/\n/,/g') '
        BEGIN{
            FS=OFS="\t";
            split(sample,sDict,",");
            for (i in sDict) sarray[sDict[i]] = ""
        }
        {
            if ($0~/^##/) {print; next}
            if ($0~/^#CHROM/) {split($0,colnames,"\t"); print; next}
            for (i=10; i<=NF; i++) {
                if ($i~/^\.\/\./) continue
                if (colnames[i] in sarray){
                    $i = "./."
                }
            }
            print $0
        }' $temp > $output
fi
