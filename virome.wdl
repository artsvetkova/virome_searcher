version 1.0

workflow {
    input{
        File bam
        String db_dir
        File fastq_unmapped
        Int thread
    }
    call filter_unmapped {
        input:
            bam = bam
    }
    call convert_to_fastq {
        input:
            bam_unmapped = filter_unmapped.bam_unmapped
            bam_basename = filter_unmapped.bam_basename
    }
    call 
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
        String bam_basename
    }
    command <<<
        samtools fastq ~{bam_basename}.unmapped.bam > ~{bam_basename}.unmapped.fastq
    >>>
    output{
        File fastq_unmapped = '~{bam_basename}.unmapped.fastq'
    }
}

task run_kraken {
    input{
            String db_dir
            File fastq_unmapped
            String bam_basename
            Int thread
    }
    command <<<
        kraken2 --db ~{db_dir} --report ~{bam_basename}.k2_report.txt --output ~{bam_basename}.k2_output.txt -threads ~{thread} ~{fastq_unmapped}
    >>>
    output{
        File k2_report = '~{bam_basename}.k2_report.txt'
        File k_output = '~{bam_basename}.k2_output.txt'
    }
}

# task extract_viral_seqIDs {
#     input{
#             # kraken output
#             File fastq_unmapped
#             # viral taxID == 10239
#     }
#     command <<<
#         python extract_kraken_reads.py 
#     >>>
#     output{

#     }
# }

# task extract_viral_reads {

# }
