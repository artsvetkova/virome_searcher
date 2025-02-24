version 1.0

workflow {
    
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
        File fasta_unmapped = '~{bam_basename}.unmapped.fastq'
    }
}

task extract_viral_seqIDs {

}

task extract_viral_reads {

}

task 