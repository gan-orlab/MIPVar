#!/bin/bash

BASE_DIR=$1

awk -v DIR=$BASE_DIR 'BEGIN{FS=OFS="\t"}{prefix=$3"_"$4; split(prefix,fol,"_"); file_name=DIR"/SKAT/"fol[1]"/"fol[2]"/"fol[3]; if(system("[ -d " file_name " ]") == 0){print $1,$2 >> file_name"/"prefix".SETID"}}' $BASE_DIR/segregation.analysis/Combined.setprep



