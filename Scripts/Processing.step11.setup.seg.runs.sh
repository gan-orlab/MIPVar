#!/bin/bash

# little useful functions and variables
RUN_DIR=$1
gene_list=$2
genes=$(cat $gene_list)
seg_script=~/runs/eyu8/soft/MIPVar/Scripts/generic.seg_command.sh
gatk=~/projects/def-grouleau/COMMON/soft/lib/java/GATK/GenomeAnalysisTK-3.8/dist/GenomeAnalysisTK.jar
REF=~/projects/def-grouleau/COMMON/soft/src/pipeline_exome.svn/data/reference/human_g1k_v37.fasta

list ()  {  if [[ $# == 1 ]]; then echo $@; else echo {$(echo $@|tr ' ' ',')}; fi;  }

header() { 
    if [[ ${#@} -eq 2 ]]; then
        file=$1;
        sep=$2;
    else
        if [[ ${#@} -eq 1 ]]; then
            file=$1;
            sep="\t";
        else
            echo "arguments: header [file] [separator (default=tab)]" return 42;
        fi;
    fi;
    head -n 1 $file | awk -F"$sep" '{for (i=1; i<=NF; i++) print i"\t"$i}'
}

process_segregation() {
    read cohort DP <<< $@
    run_prefix=PD.$cohort.$DP
    seg_dir=$RUN_DIR/segregation.analysis/$cohort/$DP
    seg_script=$seg_dir/$run_prefix.segregation.sh
    stats=$(ls -1 $RUN_DIR/*/$cohort/$DP/analysis/*stats 2>/dev/null)
    final_output=$RUN_DIR/segregation.analysis/$cohort/$DP/$run_prefix.final.output
    final_output_old=$RUN_DIR/segregation.analysis/$cohort/$DP/$run_prefix.old.final.output
    bash $seg_script
    seg_results=$(ls -1 $seg_dir/$run_prefix.output)
    last_col=$[$(header $seg_results|awk -F"\t" '$2=="Family members"'|cut -f1)-1]
    paste <(cut -f1-5 $seg_results) <(awk 'BEGIN{FS=OFS="\t"; null="\t\t\t\t\t\t\t"} {if (NR==FNR) {key=$1":"$3":"$4":"$5; value=$2"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12; a[key]=value; next}; if (FNR==1) {print "SNP","NMISS","OR","L95","U95","P","F_A","F_U"; next}; key=$2":"$3":"$4":"$5; if (key in a) {print a[key]} else {print null}}' <(awk 'FNR!=1' $stats) $seg_results) <(cut -f6-$last_col $seg_results) > $final_output_old
    awk 'BEGIN{FS=OFS="\t"}{if(FNR==NR){gene[$1]=1;next;}test=0;if($26 ~ /\|/){split($26,nearest_gene,"|");for(i in nearest_gene){if(gene[nearest_gene[i]]==1){$26=nearest_gene[i];test=1}}if(test==0){next;}}print;}' $gene_list $final_output_old > $final_output
}

# set up lists
cohorts="FC NY ISR"; DPs="15x 30x 50x"

# make all segregation analysis folders
echo making segregation folders
eval mkdir -p $RUN_DIR/segregation.analysis/$(list $cohorts)/$(list $DPs)

# create vcf files, ped files + seg commands for each analysis
echo creating seg scripts and pedigree files
for cohort in $cohorts; do
  for DP in $DPs; do
    echo ...processing $cohort $DP
    seg_dir=$RUN_DIR/segregation.analysis/$cohort/$DP
    run_prefix=PD.$cohort.$DP
    vcfs=$(eval ls -1 $RUN_DIR/$(list $genes)/$cohort/$DP/analysis/*final.vcf 2>/dev/null);
    fams=$(eval ls -1 $RUN_DIR/$(list $genes)/$cohort/$DP/analysis/*fam 2>/dev/null);
    ped=$seg_dir/$run_prefix.PED
    tmp_vcf=$seg_dir/$run_prefix.merged.raw.vcf
    vcf=$seg_dir/$run_prefix.merged.vcf
    local_seg=$seg_dir/$run_prefix.segregation.sh
    echo ......creating ped
    cat $fams|sort -u|tr ' ' '\t'|awk 'BEGIN{FS=OFS="\t"}{print "PD",$2,$3,$4,$5,$6}' > $ped
    echo ......creating vcf
    java -Xmx4g -cp $gatk org.broadinstitute.gatk.tools.CatVariants -R $REF $(printf " -V:%s %s " $(for i in $vcfs; do echo -e "$(basename $i|cut -d. -f1)\t$i"; done)) -out $vcf  --log_to_file $seg_dir/$run_prefix.CombineVariants.log 2>/dev/null
    echo ......creating seg script
    echo -e "export run=PD.$cohort.$DP\nexport VCF_LIST=\"$vcf\"\ncd $seg_dir\nbash $seg_script" > $local_seg
    echo ......running seg script
    process_segregation $cohort $DP &
  done
done
wait
