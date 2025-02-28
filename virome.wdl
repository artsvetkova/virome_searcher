version 1.0

workflow virome {
    input{
        File bam
        String db_dir
        Int thread
    }
    call filter_unmapped {
        input:
            bam = bam
    }
    call convert_to_fastq {
        input:
            bam_unmapped = filter_unmapped.bam_unmapped,
            bam_basename = filter_unmapped.bam_basename
    }
    call run_kraken {
        input:
            db_dir = db_dir,
            fastq_unmapped = convert_to_fastq.fastq_unmapped,
            bam_basename = filter_unmapped.bam_basename,
            thread = thread
    }
}


task filter_unmapped {
    input{
        File bam
    }

    command <<<
        samtools view -f 4 ~{bam} > ~{basename(bam, '.bam')}.unmapped.bam
    >>>
    output{
        File bam_unmapped = '~{basename(bam, '.bam')}.unmapped.bam'
        String bam_basename = basename(bam, '.bam')
    }
}


task convert_to_fastq {
    input{
        File bam_unmapped
        String bam_basename
    }
    command <<<
        samtools fastq ~{bam_unmapped} > ~{bam_basename}.unmapped.fastq
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
        File k2_output = '~{bam_basename}.k2_output.txt'
    }
}

