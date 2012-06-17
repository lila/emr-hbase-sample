package com.amazon.karanb.emr;

import gov.jgi.meta.hadoop.input.FastaBlockLineReader;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.rest.client.Client;
import org.apache.hadoop.hbase.rest.client.Cluster;
import org.apache.hadoop.hbase.rest.client.RemoteHTable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.Text;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;


/**
 * Created by IntelliJ IDEA.
 * User: karanb
 * Date: 3/20/12
 * Time: 2:48 PM
 * To change this template use File | Settings | File Templates.
 */
public class HBaseGenomics {
    public static void main(String[] args) {


        try {
            FileInputStream fstream = new FileInputStream("target/test-classes/1M.fas");
            FastaBlockLineReader fblr = new FastaBlockLineReader(fstream);

            Text key = new Text();
            Map<String, String> setofreads = new HashMap<String, String>();
            Map<String, String> setofreadsTotal = new HashMap<String, String>();

            fblr.readLine(key, setofreads, Integer.MAX_VALUE, Integer.MAX_VALUE);
            System.out.println("number of reads = " + setofreads.size());
        } catch (Exception e) {
            System.err.println(e);
        }

        Configuration conf = HBaseConfiguration.create();

        Cluster cluster = new Cluster();
        cluster.add("ec2-23-20-165-137.compute-1.amazonaws.com", 8080); // co RestExample-1-Cluster Set up a cluster list adding all known REST server hosts.

        Client client = new Client(cluster); // co RestExample-2-Client Create the client handling the HTTP communication.

        RemoteHTable table = new RemoteHTable(client, "kmer"); // co RestExample-3-Table Create a remote table instance, wrapping the REST access into a familiar interface.

        Scan scan = new Scan();
        scan.setStartRow(Bytes.toBytes("row-10"));
        scan.setStopRow(Bytes.toBytes("row-15"));
        scan.addColumn(Bytes.toBytes("colfam1"), Bytes.toBytes("col-5"));
        ResultScanner scanner = null; // co RestExample-5-Scan Scan the table, again, the same approach as if using the native Java API.
        try {
            scanner = table.getScanner(scan);
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }

        for (Result result2 : scanner) {
            System.out.println("Scan row[" + Bytes.toString(result2.getRow()) +
                    "]: " + result2);
        }

   }
}
