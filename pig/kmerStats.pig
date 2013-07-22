
--
-- generates kmer statistics from hbase table
--
--register s3://karanb.amazon.com/biopig/biopig-core-0.3.0-job.jar

--%default reads 's3://com.amazon.karan/ron/1.fas'
--%default biopigjar 's3://karanb.amazon.com/biopig/biopig-core-0.3.0-job.jar'

register $biopigjar

A = LOAD 'hbase://kmer'
       USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
       'sequence:*', '-loadKey true')
       AS (id:bytearray, sequence:map[]);
B = foreach A generate id, SIZE(sequence);
C = group B by $1 PARALLEL $p;
D = foreach C generate group, COUNT(B);

store D into '$output';
