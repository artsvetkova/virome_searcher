version 1.0

workflow virome {
    input{
        File aln_file
        String db_dir
        Int thread
        File? reference_fasta # if aln_file is .cram
    }
    call filter_unmapped {
        input:
            aln_file = aln_file
            reference_fasta = reference_fasta
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
        File aln_file
        File? reference_fasta  # if aln_file is .cram
    }

    command <<<
        if [[ "~{aln_file}" == *.cram ]]; then
            if [ ! -f "~{reference_fasta}" ]; then
                echo "Error: .fasta reference is required for .cram input" >&2
                exit 1
            fi
            samtools view -f 4 -b -T ~{reference_fasta} ~{aln_file} > ~{basename(aln_file, '.cram')}.unmapped.bam
        
        elif [[ "~{aln_file}" == *.sam ]]; then
            samtools view -f 4 -b ~{aln_file} > ~{basename(aln_file, '.sam')}.unmapped.bam
        
        else
            samtools view -f 4 -b ~{aln_file} > ~{basename(aln_file, '.bam')}.unmapped.bam
        fi
    >>>
    output{
        File bam_unmapped = '~{basename(bam, '.bam')}.unmapped.bam'
        String bam_basename = basename(bam, '.bam')
    }

    output {
    File bam_unmapped = if ends_with(aln_file, ".sam") then '~{basename(aln_file, '.sam')}.unmapped.bam'
        else if ends_with(aln_file, ".cram") then '~{basename(aln_file, '.cram')}.unmapped.bam'
        else '~{basename(aln_file, '.bam')}.unmapped.bam'
    
    String bam_basename = if ends_with(aln_file, ".sam") then basename(aln_file, '.sam')
        else if ends_with(aln_file, ".cram") then basename(aln_file, '.cram')
        else basename(aln_file, '.bam')
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
