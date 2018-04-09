#!/bin/bash -ex

sleep 5
 
###############################
testMenu=/cdaq/physics/Run2017/2e34/v4.0.1/HLT/V1
GT=92X_dataRun2_HLT_v7
file=$(cat files_305188.txt)
reference=$1
sqlite=DBLaser_$2
pathToMonitor=("HLT_Ele3" "HLT_PFMET120_PFMHT120_IDTight"  "HLT_Photon33" "HLT_PFMETTypeOne100_PFMHT100_IDTight_PFHT60" "HLT_Ele27_WPTight_Gsf" )
maxEvents=100000
###############################


export CMSREL=CMSSW_9_2_13
export SCRAM_ARCH=slc6_amd64_gcc630
scram -a $SCRAM_ARCH project $CMSREL
cp fastTimeAdd.py  $CMSREL/src/
cp files_305188.txt $CMSREL/src/
cd $CMSREL/src
eval `scram runtime -sh`


echo "will run : hltGetConfiguration --offline --globaltag " $GT   "--max-events 999999 --timing  --input  "$file "orcoff:"$testMenu 


wget http://cern.ch/ecaltrg/DBLaser/${sqlite}.db


hltGetConfiguration --online --globaltag $GT   --max-events $maxEvents  --input $(cat files_305188.txt) orcoff:$testMenu > hlt.py

cat fastTimeAdd.py >> hlt.py


sed 's/TOADAPT/'$sqlite'/g' hlt.py  > hlt_sqlite.py


cmsRun hlt_sqlite.py >&log_sqlite.log 

#it may be gzipped infact ...
wget https://cmssdt.cern.ch/SDT/public/EcalLaserValidation/HLT_EcalLaserValidation/${1}/log_ref_${1}.log

touch outputDiff.log
for path in ${pathToMonitor[*]}
do
   printf "checking for    %s\n" $path
   cat log_sqlite.log | grep $path >  $path\_sqlite.log
   cat log_ref_${1}.log | grep $path >  ${path}\_ref_${1}.log 
   diff $path\_sqlite.log $path\_ref_${1}.log | grep TrigReport >> outputDiff.log || true 
done

if [-f ${WORKSPACE}/upload/$2 ]
then
  echo "dir is already existing"
  touch ${WORKSPACE}/upload/$2/.jenkins-upload
else
    mkdir ${WORKSPACE}/upload/$2
    touch ${WORKSPACE}/upload/$2/.jenkins-upload
fi

#we need to make a tar gz of this one
#cp log_sqlite.log  ${WORKSPACE}/upload/${2}/log_ref_${2}.log 
cp outputDiff.log ${WORKSPACE}/upload/${2}/outputDiff.log



#awk 'NR==1 {print "pass ",$5," over ",$6," for reference path using  sqlite1"} ' $pathToMonitor\_sqlite1.log > diff.txt
#awk 'NR==1 {print "pass ",$5," over ",$6," for reference path using  sqlite2"} ' $pathToMonitor\_sqlite2.log >> diff.txt


#awk 'NR==3 {print "timing " $2," for reference path using sqlite1"} ' $pathToMonitor\_sqlite1.log >> diff.txt
#awk 'NR==3 {print "timing " $2," for reference path using sqlite2"} ' $pathToMonitor\_sqlite2.log >> diff.txt


