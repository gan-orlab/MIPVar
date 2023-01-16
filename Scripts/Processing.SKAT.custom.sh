#!/bin/bash

BASE_DIR=$1
gene_list=$2
covar=$3
cohort=$4

SCRIPT_FOLDER=~/MIPVar/Scripts

bash $SCRIPT_FOLDER/Processing.step12.VariantsSelection.custom.sh $BASE_DIR $SCRIPT_FOLDER $covar $cohort

bash $SCRIPT_FOLDER/Processing.step13.RareVarsSubgroups.custom.sh $BASE_DIR $cohort 

bash $SCRIPT_FOLDER/Processing.step14.SETIDprep.custom.sh $BASE_DIR $cohort

bash $SCRIPT_FOLDER/Processing.step15.SKATFolderSetup.custom.sh $BASE_DIR $gene_list $cohort

bash $SCRIPT_FOLDER/Processing.step16.MovingSKATFiles.custom.sh $BASE_DIR $gene_list $cohort

bash $SCRIPT_FOLDER/Processing.step17.MovingSetPrep.sh $BASE_DIR 

bash $SCRIPT_FOLDER/Processing.step18.SKAT.custom.sh $BASE_DIR $gene_list $SCRIPT_FOLDER $cohort
