#!/bin/bash -ex


echo "Running automated fast track validation script. Will compare rates and timing of menus using"
echo "reference and test sqlite files"
echo " "

echo " edit testMenu, file and sqlites files, etc.... in the first section"
sleep 5
 
###############################
testMenu=/cdaq/physics/Run2017/2e34/v4.0.1/HLT/V1
GT=92X_dataRun2_HLT_v7
file=$(cat files_305183.txt)
sqlite1=DBLaser_304859
sqlite2=DBLaser_305112
pathToMonitor=("HLT_Ele35_WPTight_Gsf" "HLT_PFMET120_PFMHT120_IDTight"  "HLT_Photon33"  "HLT_PFJet450" "HLT_PFMETTypeOne120_PFMHT120_IDTight_PFHT60" "HLT_Ele27_WPTight_Gsf" )
###############################


export CMSREL=CMSSW_9_2_13
export SCRAM_ARCH=slc6_amd64_gcc630
scram -a $SCRAM_ARCH project $CMSREL
cp fastTimeAdd_new.py  $CMSREL/src/
cp files_305183.txt $CMSREL/src/
cd $CMSREL/src
eval `scram runtime -sh`


echo "will run : hltGetConfiguration --offline --globaltag " $GT   "--max-events 999999 --timing  --input  "$file "orcoff:"$testMenu 
#echo "will run : hltGetConfiguration --offline --globaltag auto:run2_hlt_GRun --max-events 999999 --timing  --input  "$file "orcoff:"$testMenu 


hltGetConfiguration --online --globaltag $GT   --max-events 99999  --input $(cat files_305183.txt) orcoff:$testMenu > hlt.py
#hltGetConfiguration --online --globaltag auto:run2_hlt_GRun   --max-events 99999  --input $(cat files_305183.txt) orcoff:$testMenu > hlt.py

cat fastTimeAdd_new.py >> hlt.py



sed 's/TOADAPT/'$sqlite1'/g' hlt.py  > hlt_sqlite1.py
sed 's/TOADAPT/'$sqlite2'/g' hlt.py  > hlt_sqlite2.py




cmsRun hlt_sqlite1.py >&log_sqlite1.log 
cmsRun hlt_sqlite2.py >&log_sqlite2.log 

for path in ${pathToMonitor[*]}
do
   printf "checking for    %s\n" $path
   cat log_sqlite1.log | grep $path >  $path\_sqlite1.log
   cat log_sqlite2.log | grep $path >  $path\_sqlite2.log 
   diff $path\_sqlite1.log $path\_sqlite2.log | grep TrigReport >> $path\_diff.log || true
done




#cat log_sqlite1.log | grep $pathToMonitor >  $pathToMonitor\_sqlite1.log 
#cat log_sqlite2.log | grep $pathToMonitor >  $pathToMonitor\_sqlite2.log 


#awk 'NR==1 {print "pass ",$5," over ",$6," for reference path using  sqlite1"} ' $pathToMonitor\_sqlite1.log > diff.txt
#awk 'NR==1 {print "pass ",$5," over ",$6," for reference path using  sqlite2"} ' $pathToMonitor\_sqlite2.log >> diff.txt


#awk 'NR==3 {print "timing " $2," for reference path using sqlite1"} ' $pathToMonitor\_sqlite1.log >> diff.txt
#awk 'NR==3 {print "timing " $2," for reference path using sqlite2"} ' $pathToMonitor\_sqlite2.log >> diff.txt


#echo " difference in counts and timing using the two sqlite files is "
#cat diff.txt

#wget https://raw.githubusercontent.com/cms-steam/TimingScripts/master/MenuValidation/TimingAndRates.py 
#wget https://raw.githubusercontent.com/cms-steam/TimingScripts/master/MenuValidation/TimingAndRates.cc .
#python TimingScripts/Scripts/plotPath_Timing.py --inputfiles DQM_XXXX.root --process TIMING --runs XXX --paths HLT_XXXXX


#python TimingAndRates.py --run 293492 --data --lumis 999999 --inputfile DQM_V0001_R000293645__HLT__FastTimerService__All.root
