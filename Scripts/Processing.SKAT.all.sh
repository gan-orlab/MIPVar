#!/bin/bash

BASE_DIR=$1
gene_list=$2
covar=$3

SCRIPT_FOLDER=~/MIPVar/Scripts

bash $SCRIPT_FOLDER/Processing.step12.VariantsSelection.all.sh $BASE_DIR $SCRIPT_FOLDER $covar

bash $SCRIPT_FOLDER/Processing.step13.RareVarsSubgroups.all.sh $BASE_DIR

bash $SCRIPT_FOLDER/Processing.step14.SETIDprep.all.sh $BASE_DIR

bash $SCRIPT_FOLDER/Processing.step15.SKATFolderSetup.all.sh $BASE_DIR $gene_list

bash $SCRIPT_FOLDER/Processing.step16.MovingSKATFiles.all.sh $BASE_DIR $gene_list

bash $SCRIPT_FOLDER/Processing.step17.MovingSetPrep.sh $BASE_DIR 

bash $SCRIPT_FOLDER/Processing.step18.SKAT.all.sh $BASE_DIR $gene_list $SCRIPT_FOLDER
