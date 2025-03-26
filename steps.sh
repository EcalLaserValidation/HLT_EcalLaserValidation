#!/bin/bash -ex
file=`ls RunFiles/`
echo $file
if [ -f ToRun/$file ]
then
echo ToRun/$file
    year=`grep "year" ToRun/$file | awk '{print $2}'`
    week=`grep "week" ToRun/$file | awk '{print $2}'`
    sqliteRef=`grep "run1" ToRun/$file | awk '{print $2}'`
    sqliteNew=`grep "run2" ToRun/$file | awk '{print $2}'`
    label=`grep "type" ToRun/$file | awk '{print $2}'`
cp ToRun/$file RunFiles/.
rm ToRun/$file
echo "./runHLTEcalLaserValidation_2025.sh $sqliteRef $sqliteNew $label $week"
line="files_Run_323775.txt"
#split -n l/9 --numeric-suffixes files_Run_323775.txt files_Run_323775_split_
#ls files_Run_323775_split_* > ls_files_Run_323775_split.txt
#nn=0
#for line in $(less ls_files_Run_323775_split.txt)
#do
#    nn=$[$nn+1]
#    ./runHLTEcalLaserValidation_2025.sh $sqliteRef $sqliteNew $label $week $(getconf _NPROCESSORS_ONLN) $line $nn &
    ./runHLTEcalLaserValidation_2025.sh $sqliteRef $sqliteNew $label $week $(getconf _NPROCESSORS_ONLN) 
#done
#wait
#./harvest_2025.sh $sqliteRef $sqliteNew $label
else
echo "No new files"
fi
