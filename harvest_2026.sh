#!/bin/bash -ex
pathToMonitor=("HLT_Ele32_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_v" "HLT_Ele35_WPTight_Gsf_L1EGMT_v" "HLT_Ele38_WPTight_Gsf_v" "HLT_Ele30_eta2p1_WPTight_Gsf_CentralPFJet35_EleCleaned_v" "HLT_Photon33_v" "HLT_PFMET120_PFMHT120_IDTight_v" "HLT_PFMET100_PFMHT100_IDTight_PFHT60_v" "HLT_PFMETTypeOne120_PFMHT120_IDTight_v" )

ls log_sqlite_*.log > ls_log_sqlite.txt
for line in $(less ls_log_sqlite.txt)
do
    for path in ${pathToMonitor[*]}
    do
	printf "checking for    %s\n" $path
	cat $line | grep $path | grep TrigReport | grep -v "\-----" | awk '{if ($5 != 0) print "New normalized rate for path ", $8, $5*2000/$4}' >> output_sqlite_$path.log
    done
done

for path in ${pathToMonitor[*]}
do
    awk -F" " '{sum+=$7}END{print "New normalized rate for path " $6,int(sum)}' output_sqlite_$path.log >> output_sqlite.log
done

if [[ `wget -S --spider https://cmssdt.cern.ch/SDT/public/EcalLaserValidation/HLT_EcalLaserValidation/${1}_${3}/output_ref_${1}_${3}.log 2>&1 | grep 'HTTP/1.1 200 OK'` ]]
	then 
    	wget https://cmssdt.cern.ch/SDT/public/EcalLaserValidation/HLT_EcalLaserValidation/${1}_${3}/output_ref_${1}_${3}.log
	else
		if [[ `wget -S --spider https://ecaltrg.web.cern.ch/ecaltrg/ReferenceNTuples/HLT/${3}/output_ref_${1}_${3}.log  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
		then
    		wget https://ecaltrg.web.cern.ch/ecaltrg/ReferenceNTuples/HLT/${3}/output_ref_${1}_${3}.log
		else
   		#cp output_ref_349295_pedestal.log output_ref_${1}_${3}.log
    		mail -s "used output_ref_349295_pedestal.log  " ecaltrg@cern.ch <<< "output_ref_349295_pedestal.log used"
	fi
fi
touch outputDiff.log  
for path in ${pathToMonitor[*]}
do
   printf "checking for    %s\n" $path
   cat output_sqlite.log | grep $path | awk '{if ($7 != 0) print "New normalized rate for path ", $6, $7}' >> outputDiff.log 
   cat output_ref_${1}_${3}.log | grep $path | awk '{if ($7 !=0)  print "Ref normalized rate for path ", $6, $7}' >> outputDiff.log 
done


if [ -f ${WORKSPACE}/upload/${2}_${3} ]
then
  echo "dir is already existing"
  touch ${WORKSPACE}/upload/${2}_${3}/.jenkins-upload
else
    mkdir ${WORKSPACE}/upload/${2}_${3}
    touch ${WORKSPACE}/upload/${2}_${3}/.jenkins-upload
fi

#we need to make a tar gz of this one
cp output_sqlite.log  ${WORKSPACE}/upload/${2}_${3}/output_ref_${2}_${3}.log 
cp outputDiff.log ${WORKSPACE}/upload/${2}_${3}/outputDiff.log



