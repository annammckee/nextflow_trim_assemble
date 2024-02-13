#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// set param values
params.reads = "$baseDir/data/*_{R1,R2}.fastq.gz"
params.outdir = "$baseDir/results"

//process that trims the input FastQ files using Trimmomatic
process TrimReads {
    // tag each job with the pair identifier
    tag "${pair_id}"

    //specifies where to place the output files
    publishDir "${params.outdir}/trimmed", mode: 'copy'

    //block declares expected inputs (a tuple with a pair identifier and paths to the two FastQ files
    input:
    tuple val(pair_id), path(read1), path(read2)

    //block specifies the output files (trimmed FastQ files
    output:
    tuple val(pair_id), path("${pair_id}_R1.trimmed.fastq.gz"), path("${pair_id}_R2.trimmed.fastq.gz")

    //block contains the command to run Trimmomatic, including parameters for paired-end trimming and quality filtering
    script:
    """
    trimmomatic PE -phred33 \\
        $read1 $read2 \\
        ${pair_id}_R1.trimmed.fastq.gz ${pair_id}_R1.unpaired.fastq.gz \\
        ${pair_id}_R2.trimmed.fastq.gz ${pair_id}_R2.unpaired.fastq.gz \\
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:8:true SLIDINGWINDOW:4:15 MINLEN:36
    """
}


// Defines a process for assembling the trimmed reads into contigs using SPAdes
process AssembleFasta {

    //block declares the inputs (a tuple with a pair identifier and paths to the two trimmed FastQ files)
    tag "${pair_id}"
    
    //specifies where to place the output files
    publishDir "${params.outdir}/assembly", mode: 'copy'

    //block declares the inputs (a tuple with a pair identifier and paths to the two trimmed FastQ files)
    input:
    tuple val(pair_id), path(r1_trimmed), path(r2_trimmed)

    //block specifies the output (the assembly result)
    output:
    path("${pair_id}.assembly")

    //block contains the command to run SPAdes with the trimmed reads as input
    script:
    """
    spades.py -1 $r1_trimmed -2 $r2_trimmed -o ${pair_id}.assembly
    """
}


//Defines the workflow block that orchestrates the execution of the defined processes
workflow {
    //create Channel from paired-end read files using the Channel.fromFilePairs method with the params.reads pattern
    read_pairs = Channel.fromFilePairs(params.reads, size: 2, flat: true)

    //captures the output from the TrimReads process, which is then piped into the AssembleFasta process
    trimmed_reads = read_pairs
        | TrimReads

    assembled_fasta = trimmed_reads
        | AssembleFasta

    // output of AssembleFasta is stored in the assembled_fasta variable, 
    //which is then used to display a completion message for each assembled fasta file using the .view method
    assembled_fasta
        .view { it -> "Assembly completed: ${it}" }
}