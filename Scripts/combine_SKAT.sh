#!/bin/bash

folder=$1
i=$2

 paste -d ' ' <(grep RareAll $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.skato | cut -d ' ' -f2) <(grep RareAll $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.burden | cut -d ' ' -f2) <(grep RareCADD $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.skato | cut -d ' ' -f2) <(grep RareCADD $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.burden | cut -d ' ' -f2) <(grep RareFunct $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.skato | cut -d ' ' -f2) <(grep RareFunct $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.burden | cut -d ' ' -f2) <(grep RareNS $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.skato | cut -d ' ' -f2) <(grep RareNS $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.burden | cut -d ' ' -f2) <(grep RareLOF $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.skato | cut -d ' ' -f2) <(grep RareLOF $folder/PARK2/${i}/30x/PARK2_${i}_30x.results.burden | cut -d ' ' -f2)
