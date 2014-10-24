Utils
=====

Just a bunch of scripts to search for running workflows with steps that have been running too long.

To run it:

Change the "AWS_completed_report.sh" and "AWS_running_report.sh" scripts and:

- set the correct path to your SSH key and create the /root/aws-creds.sh holding your AWS credentials.
- set the directory where the reports will be stored
- change the region and/or AWS tag used by your cluster

Change the "check-seqware-jobs-duration.sh" script and add different values for the variables at top if needed:

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

