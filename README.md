# HLT_EcalLaserValidation
short script ecal laser calibrations fast validation at HLT

####  To make a PR and trigger the jenkins test  #######

git init

git clone https://github.com/EcalLaserValidation/HLT_EcalLaserValidation.git

cd  HLT_EcalLaserValidation

git checkout -b "newBranch_dateXXX"

modify what you have to modify ...

git commit -m "please test" *

git push origin newBranch_dateXXX

git pull-request -m "$(git log -1 --pretty=%B)"



##### To run locally #######



1. to be used in bash

2.  edit the first section of step.sh 

testMenu=/cdaq/physics/Run2017/2e34/v4.0.1/HLT/V1
GT=92X_dataRun2_HLT_v7
file=$(more files_305188.txt)
sqlite1=DBLaser_293491
sqlite2=DBLaser_292925
pathToMonitor=("HLT_Ele35_WPTight_Gsf" "HLT_PFMET110_PFMHT110_IDTight"  "HLT_Photon33"  "HLT_PFJet450" "HLT_PFMETTypeOne100_PFMHT100_IDTight_PFHT60" "HLT_Ele27_WPTight_Gsf" )



3. also change the CMSSW relase below if needed


4. then source step.sh


in a test I did I got this finally

difference in counts and timing using the two sqlite files is 

pass  1  over  4999  for reference path using  sqlite1

pass  0  over  4999  for reference path using  sqlite2

timing 0.030172  for reference path using sqlite1

timing 0.027120  for reference path using sqlite2
