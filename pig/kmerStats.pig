
--
-- generates kmer statistics from a fasta file
--
--register s3://karanb.amazon.com/biopig/biopig-core-0.3.0-job.jar

--%default reads 's3://com.amazon.karan/ron/1.fas'
--%default biopigjar 's3://karanb.amazon.com/biopig/biopig-core-0.3.0-job.jar'

register $biopigjar

A = load '$reads' using gov.jgi.meta.pig.storage.FastaStorage as (id: chararray, d: int, seq: bytearray);
B = foreach A generate FLATTEN(gov.jgi.meta.pig.eval.KmerGenerator(seq, 21)) as (kmer:bytearray), id;

--B = load 'kmer' using org.apache.pig.backend.hadoop.hbase.HBaseStorage('sequence:id sequence:value');
STORE B INTO 'hbase://kmer'
        USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
              'sequence:id sequence:id');

