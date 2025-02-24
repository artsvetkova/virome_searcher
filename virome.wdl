version 1.0

workflow {
    input{
        File bam
        String db_dir
    }
}

task filter_unmapped {
    input{
        File bam
    }
    String bam_basename = basename(bam, '.bam')
    command <<<
        samtools view -f 4 ~{bam} > ~{bam_basename}.unmapped.bam
    >>>
    output{
        File bam_unmapped = '~{bam_basename}.unmapped.bam'
        String bam_basename
    }
}

task convert_to_fastq {
    input{
        File bam_unmapped
    }
    command <<<
        samtools fastq ~{bam_basename}.unmapped.bam > ~{bam_basename}.unmapped.fastq
    >>>
    output{
        File fastq_unmapped = '~{bam_basename}.unmapped.fastq'
    }
}

task run_kraken{
    input{
            File db_dir
            File fastq_unmapped
            Int thread
    }
    command <<<
        kraken2 --db ~{db_dir} --report kraken_report.txt --output kraken_output.txt -threads ~{thread} ~{fastq_unmapped}
    >>>
    output{
        File k_report = 'kraken_report.txt'
        File k_output = 'kraken_output.txt'
    }
}

task extract_viral_seqIDs {
    input{

    }
    command <<<
        python extract_kraken_reads.py 
    >>>
    output{

    }
}

task extract_viral_reads {

}
