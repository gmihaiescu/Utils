#!/bin/bash
#set -x

# Set these variables with correct values
# The following values are considered to be in HOURS
bam_stats=5
bwa_mem=25
gtdownload=3
mergeBAM=18
unmappedReads=3
upload=10
accession=21

# The following values are considered to be in kB/s
upload_rate_alert=100
download_rate_alert=1000

for workflow in `sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession $accession | grep -A 4 -B 1 running| grep 'Workflow Run Engine ID'| awk -F"|" '{print $2}'`;\
do \
	for step in `oozie job -info $workflow -oozie http://localhost:11000/oozie | grep RUNNING| grep 0000| awk -F"@" '{print $2}'| awk '{print $3}'`;\
	do \
		startlong=`sudo -u seqware -i /usr/bin/qstat -f | grep $step| awk '{print $6, $7}'`;\
		startshort=`date -d "$startlong" +"%s"`;\
		curtime=`date +%s`;\
		diff=$(($curtime-startshort));\
		hours=$((diff / 3600));\
		step_name=`sudo -u seqware -i /usr/bin/qstat -f | grep $step| awk '{print $3}'`
		work_dir=`sudo -u seqware -i /home/seqware/bin/seqware workflow report --accession 21| grep -B1 $workflow | grep "Workflow Run Working Dir" | awk -F"|" '{print $2}'`
		
		case $step_name in
			bam*)	if [ $hours -gt $bam_stats ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
					else echo "No problems detected."
					exit 0
				fi 
			;;
			bwa*)	if [ $hours -gt $bwa_mem ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
					else echo "No problems detected."
					exit 0
				fi 
			;;
			gtdownload*)	log_file_small=`oozie job -info $workflow -oozie http://localhost:11000/oozie | grep RUNNING| grep 0000| awk -F"@" '{print $2}'| cut -f1 -d" "`	
					log_file_long=`find $work_dir -name "download.log"`
					download_rate=`grep Status $log_file_long | tail -5 | awk '{ if ($13 == "MB/s") sum += $12*1024; else sum += $12; n++ } END { if (n > 0) print sum / n; }'`
					if [ $hours -gt $gtdownload ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours and downloading at a rate of $download_rate kB/s."
					exit 2
					elif [ $download_rate -lt $download_rate_alert ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name is downloading at a rate of $download_rate kB/s."
					exit 2
					else echo "No problems detected."
					exit 0
				fi 
			;;
			merge*)	if [ $hours -gt $mergeBAM ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
					else echo "No problems detected."
					exit 0
				fi 
			;;
			unmappedReads*)	if [ $hours -gt $unmappedReads ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
					else echo "No problems detected."
					exit 0
				fi 
			;;
			upload*)	log_file_small=`oozie job -info $workflow -oozie http://localhost:11000/oozie | grep RUNNING| grep 0000| awk -F"@" '{print $2}'| cut -f1 -d" "`	
					log_file_long=`find $work_dir -name "upload.log"`
					upload_rate=`grep Status $log_file_long | tail -5 | awk '{ if ($13 == "MB/s") sum += $12*1024; else sum += $12; n++ } END { if (n > 0) print sum / n; }'`
					if [ $hours -gt $upload ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours and is uploading at a rate of $upload_rate kB/s."
					exit 2
					elif [ $upload_rate -lt $upload_rate_alert ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name is uploading at a rate of $upload_rate kB/s."
					else echo "No problems detected."
					exit 0
				fi 
			;;
			*)  echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
			;;
		esac
	done
done

