# Makefile for PingServer

#
# commands setup
# 
EMR                     = elastic-mapreduce
S3CMD                   = s3cmd

#
# variables
#
REGION                  = us-east
KEY			= normal

# 
# make targets 
#

help:
	@echo "help for Makefile for AWS-CF-genome-alignment"
	@echo "make create - launch the hbase cluster on aws"
	@echo "make destroy - destroy the cluster"
	@echo "make test - just some testing"

test:
	@ echo "user = " $(USER);

clean: cleanbootstrap
	@echo "removed all unnecessary files"

create: bootstrap 
	@ echo creating EMR cluster
	${EMR} elastic-mapreduce --create --alive --name "$(USER)'s HBase genomics cluster" \
	  --num-instances 2 \
	  --instance-type cc1.4xlarge \
	  --bootstrap-action s3://beta.elasticmapreduce/hbase-beta/install-hbase-stage-1 \
	  --args s3://beta.elasticmapreduce/hbase-beta \
	  --bootstrap-action s3://us-east-1.elasticmapreduce/bootstrap-actions/configure-hadoop \
	  --args -m,dfs.support.append=true | cut -d " " -f 4 > ./jobflowid

destroy: cleanbootstrap
	@ echo deleting server stack genome-alignment
	${EMR} -j `cat ./jobflowid` --terminate
	rm ./jobflowid
	rm ./hbasetable

bootstrap: 
	-${S3CMD} mb s3://$(USER).hbase.genome
	${S3CMD} sync --acl-public ./lib s3://$(USER).hbase.genome/ 
	${S3CMD} sync --acl-public ./data s3://$(USER).hbase.genome/ 
	${S3CMD} sync --acl-public ./pig s3://${USER}.hbase.genome/ 

cleanbootstrap:
	-${S3CMD} -f rb s3://$(USER).hbase.genome


hbasetable: 
	${EMR} -j `cat ./jobflowid` --ssh "\"echo create \\'kmer\\', \\'sequence\\' > createtable\" "
	${EMR} -j `cat ./jobflowid` --ssh " \"bin/hbase shell <  createtable \" "
	touch hbasetable

hbasetable2: 
	${EMR} -j `cat ./jobflowid` --ssh "\"echo create \\'activity_logs\\', \\'info\\' > createtable\" "
	${EMR} -j `cat ./jobflowid` --ssh " \"bin/hbase shell <  createtable \" "
	touch hbasetable


# index uses pig to index a sequence files and add the index values to hbase
import_activity_logs: hbasetable2
	${EMR} -j `cat ./jobflowid` --jar s3://$(USER).hbase.genome/lib/pig-0.9.2-withouthadoop.jar --arg -p --arg reads=s3://$(USER).hbase.genome/data/activity_log_1m.txt.out --arg -p --arg output=s3://$(USER).hbase.genome/output --arg s3://${USER}.hbase.genome/pig/importActivityLogs.pig



index: hbasetable
	${EMR} -j `cat ./jobflowid` --jar s3://$(USER).hbase.genome/lib/pig-0.9.2-withouthadoop.jar --arg -p --arg reads=s3://$(USER).hbase.genome/data/1.fas --arg -p --arg biopigjar=s3://$(USER).hbase.genome/lib/biopig-core-0.3.0-job.jar --arg -p --arg output=s3://$(USER).hbase.genome/output --arg s3://${USER}.hbase.genome/pig/kmerStats.pig

logs: 
	${EMR} -j `cat ./jobflowid` --logs

ssh:
	${EMR} -j `cat ./jobflowid` --ssh
