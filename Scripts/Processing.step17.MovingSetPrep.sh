#!/bin/bash

BASE_DIR=$1

for gene in $(paste -d '~' <( cut -f3 $BASE_DIR/segregation.analysis/Combined.setprep) <(cut -f4 $BASE_DIR/segregation.analysis/Combined.setprep) | sort -u);
    do prefix=${gene//\~/_};
    IFS='_' read -r -a subfolder <<< "$prefix"
    folder_name=`echo $BASE_DIR"/SKAT/"${subfolder[0]}"/"${subfolder[1]}"/"${subfolder[2]}`
    file_name=`echo $folder_name"/"$prefix".SETID"`
    if [ -d $folder_name ]
    then grep "${gene//\~/	}" $BASE_DIR/segregation.analysis/Combined.setprep | awk -v file_name=$file_name 'BEGIN{FS=OFS="\t";}{print $1,$2 > file_name}' 
    fi
    done
        #awk -v DIR=$BASE_DIR 'BEGIN{FS=OFS="\t"}{prefix=$3"_"$4; split(prefix,fol,"_"); file_name=DIR"/SKAT/"fol[1]"/"fol[2]"/"fol[3]; if(system("[ -d " file_name " ]") == 0){print $1,$2 >> file_name"/"prefix".SETID"}}' $BASE_DIR/segregation.analysis/Combined.setprep



