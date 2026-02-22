#!/bin/bash -ex

sleep 5
 
###############################
#testMenu=/cdaq/physics/Run2018/2e34/v2.0.1/HLT/V1
#GT=101X_dataRun2_HLT_v7
#GT=101X_dataRun2_HLT_SiPixelQualityv9_v1
reference=$1
#listaFiles=files_Run_357271.txt
#listaFiles=files_Run_362720.txt
#listaFiles=files_Run_367696.txt
listaFiles=files_Run_380647.txt
#listaFiles=files_Run_355921.txt: failed to run with these data so went back to the data of ERA-G 362720

#listaFiles=$6
sqlite=DBLaser_${2}_moved_to_1
sqlitePED=Pedes_${2}
#sqlitePULSE=ecaltemplates_popcon_run_${2}
sqlitePULSE=ecaltemplates_popcon_fill_${2}
sqliteTIME=ecaltimingic_popcon_run_${2}
pathToMonitor=("HLT_Ele32_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_L1EGMT_v" "HLT_Ele38_WPTight_Gsf_v" "HLT_Ele30_eta2p1_WPTight_Gsf_CentralPFJet35_EleCleaned_v" "HLT_Photon33_v" "HLT_PFMET120_PFMHT120_IDTight_v" "HLT_PFMET100_PFMHT100_IDTight_PFHT60_v" "HLT_PFMETTypeOne120_PFMHT120_IDTight_v" )
maxEvents=2000
max_file_num=64
job=$7
###############################
jobs_in_parallel=$5
if [ "$jobs_in_parallel" = "" ] ; then jobs_in_parallel=1; fi
if [ "$job" = "" ] ; then job=1; fi


echo "listaFiles = "$listaFiles

#export CMSREL=CMSSW_10_1_4
#export SCRAM_ARCH=slc6_amd64_gcc630
#scram -a $SCRAM_ARCH project $CMSREL
#export CMSREL=CMSSW_13_0_6
#export SCRAM_ARCH=slc7_amd64_gcc11
export CMSREL=CMSSW_14_0_6
export SCRAM_ARCH=el8_amd64_gcc12
scram -a $SCRAM_ARCH project $CMSREL

#harvest.sh
cp harvest_2026.sh $CMSREL/src/.
cp output_ref_349295_pedestal.log $CMSREL/src/.
#listaFiles 
cp $listaFiles $CMSREL/src/.
#2024: hltGetConfiguration /dev/CMSSW_14_0_0/GRun/V107 --globaltag 140X_dataRun3_HLT_v3  --data --prescale 2p0E34+ZeroBias+HLTPhysics --output minimal --max-events 2000 --eras Run3 --l1-emulator uGT --l1 L1Menu_Collisions2024_v1_1_0_xml > hlt.py
#2023: new 2023 dataset: new hlt.py produced with: hltGetConfiguration /dev/CMSSW_13_0_0/GRun/V115  --data --process MYHLT --type GRun  --prescale 2p0E34+ZeroBias+HLTPhysics --globaltag 130X_dataRun3_HLT_v2  --max-events -1 > hlt.py_v1306 in release under zghiche...run3/TPLasVal_1306/src
#2023 hlt.py from Sanu Varghese otained with: hltGetConfiguration /dev/CMSSW_13_0_0/GRun/V8  --data --process MYHLT --type GRun  --prescale 2p0E34+ZeroBias+HLTPhysics --globaltag 130X_dataRun3_HLT_v2  --max-events -1 > hlt.py
#hlt.py got from Sam Harper: https://www.cern.ch/sharper/cms/trig/2022/hlt_1235_2018cust.py
#not uptodate hltGetConfiguration  /dev/CMSSW_12_0_0/GRun --full --offline --no-output --data --process MYHLT --type GRun --prescale 2.0e34+ZB+HLTPhysics --globaltag auto:run3_hlt_GRun --max-events -1 > hlt.py and changes therin

cp hlt.py $CMSREL/src/.
#cp output_ref_${1}_${3}.log $CMSREL/src/. #only for the first time test to be commented
#cp output_sqlite.log $CMSREL/src/. #only for the first time test to be commented
cd $CMSREL/src
eval `scram runtime -sh`


#2018 :echo "will run : hltGetConfiguration --offline --globaltag " $GT   "--max-events 999999 orcoff:"$testMenu 
#2018: hltGetConfiguration --online --globaltag $GT   --max-events $maxEvents  orcoff:$testMenu > hlt.py


        s=0
        for myfile in `less $listaFiles`  

        do
            echo $myfile 
            s=$[$s+1]
            if (( "$s" <= "$max_file_num")) || (("$max_file_num" < 0 ))
            then
		cp hlt.py hlt_$job_${s}.py
		echo "process.source.fileNames = cms.untracked.vstring()" >> hlt_$job_${s}.py
		echo "process.source.fileNames.extend([" >>hlt_$job_${s}.py
		echo $myfile >> hlt_$job_${s}.py
		echo "])" >> hlt_$job_${s}.py

		sed -e "s,%maxevents%,$maxEvents,g" -i hlt_$job_${s}.py
		#cat fastTimeAdd.py >> hlt_$job_${s}.py
		echo "process.options = cms.untracked.PSet(
                wantSummary = cms.untracked.bool( True ),
                #numberOfThreads = cms.untracked.uint32( $(nproc) ),
                numberOfThreads = cms.untracked.uint32( 1 ),
                numberOfStreams = cms.untracked.uint32( 0 ),
                sizeOfStackForThreadsInKB = cms.untracked.uint32( 10*1024 )
                )" >> hlt_$job_${s}.py

		if [ $3 = "laser" ]
		then
		    echo "process.GlobalTag.toGet = cms.VPSet(
                    cms.PSet(record = cms.string(\"EcalLaserAPDPNRatiosRcd\"),
                    tag = cms.string(\"EcalLaserAPDPNRatios_${2}_beginning_at_1\"),
                    connect = cms.string(\"sqlite_file:${sqlite}.db\")
                             )
			#,
                    #cms.PSet(record = cms.string(\"EcalLaserAlphasRcd\"),
                    #tag = cms.string(\"EcalLaserAlphas_UL_Run1_Run2_2018_lastIOV_movedTo1\"),
                    #connect = cms.string(\"frontier://FrontierProd/CMS_CONDITIONS\")
                    #          ),
                    #cms.PSet(record = cms.string(\"EcalIntercalibConstantsRcd\"),
                    #tag = cms.string(\"EcalIntercalibConstants\"),
                    #connect = cms.string(\"sqlite:////afs/cern.ch/work/c/camendol/public/ecal/ICs/2023/startup.2022Dics_etascale.gain_correction.db\")
                    #          )
                    )" >>hlt_$job_${s}.py
		    if [ ! -f ${sqlite}.db ]; then wget http://cern.ch/ecaltrg/DBLaser/${sqlite}.db;fi
		fi
		if [ $3 = "pedestal" ]
		then
		    echo "process.GlobalTag.toGet = cms.VPSet(
                    cms.PSet(record = cms.string(\"EcalPedestalsRcd\"),
                    tag = cms.string(\"EcalPedestals_hlt\"),
                    connect = cms.string(\"sqlite_file:${sqlitePED}.db\")
                              )
                    )">>hlt_$job_${s}.py
		    if [ ! -f ${sqlitePED}.db ]; then wget http://cern.ch/ecaltrg/DBPedestals/${sqlitePED}.db;fi
		fi
		if [ $3 = "pulse" ]
		then
		    echo "process.GlobalTag.toGet = cms.VPSet(
                    cms.PSet(record = cms.string(\"EcalPulseShapesRcd\"),
                    #tag = cms.string(\"EcalPulseShapes_${2}_beginning_at_1\"),
                    #connect = cms.string(\"sqlite_file:${sqlitePULSE}.db\")
                    tag = cms.string(\"EcalPulseShapes_data\"),
                    connect = cms.string(\"sqlite_file:${sqlitePULSE}.db\")
                              )
                    )">>hlt_$job_${s}.py
                    #if [ ! -f ${sqlitePULSE}.db ]; then wget https://emanuele.web.cern.ch/emanuele/public/ECAL/jenkins/devel/${sqlitePULSE}.db;fi
                    if [ ! -f ${sqlitePULSE}.db ]; then wget  http://cern.ch/ecaltrg/DBPulseShape/${sqlitePULSE}.db;fi
		    
		    #echo "process.GlobalTag.toGet = cms.VPSet(
		    #  cms.PSet(record = cms.string(\"EcalTimeCalibConstantsRcd\"),
		    #           tag = cms.string(\"EcalTimeCalibConstants_${2}_beginning_at_1\"),
		    #           connect = cms.string(\"sqlite_file:${sqliteTIME}.db\")
		    #          )
		    #)">> hlt.py
		    #if [ ! -f ${sqliteTIME}.db ]; then wget https://emanuele.web.cern.ch/emanuele/public/ECAL/jenkins/devel/${sqliteTIME}.db;fi

		fi

		#edmConfigDump hlt.py > hlt_config.py
		if [ $jobs_in_parallel -gt 1 ] ; then
                      while [ $(jobs | wc -l) -ge $jobs_in_parallel ] ; do sleep 5 ; done
		       echo "running #cmsRun hlt_$job_${s}.py >&log_sqlite_$job_${s}.log &"
		       cmsRun hlt_$job_${s}.py >&log_sqlite_$job_${s}.log &
                    else
  		       echo "#cmsRun hlt_$job_${s}.py >&log_sqlite_$job_${s}.log "
  		       cmsRun hlt_$job_${s}.py >&log_sqlite_$job_${s}.log 
                fi

	    fi	
	done
	wait

#harvest.sh
#cp log_sqlite_* ../../.
echo " running ./harvest_2026.sh $1 $2 $3"
./harvest_2026.sh $1 $2 $3

	
	
