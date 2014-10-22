#!/bin/bash
#set -x
bam_stats=5
bwa_mem=25
gtdownload=3
mergeBAM=18
unmappedReads=3
upload=10
accession=21

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
			gtdownload*)	if [ $hours -gt $gtdownload ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
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
			upload*)	if [ $hours -gt $upload ]
        				then echo "The job with Workflow Run Engine ID $workflow step ID $step doing $step_name has been running for $hours hours"
					exit 2
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
