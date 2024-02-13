#!/bin/bash -ue
trimmomatic PE -phred33 \
    HI.4019.002.index_7.ANN0831_R1.fastq.gz HI.4019.002.index_7.ANN0831_R2.fastq.gz \
    HI.4019.002.index_7.ANN0831_R1.trimmed.fastq.gz HI.4019.002.index_7.ANN0831_R1.unpaired.fastq.gz \
    HI.4019.002.index_7.ANN0831_R2.trimmed.fastq.gz HI.4019.002.index_7.ANN0831_R2.unpaired.fastq.gz \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:8:true SLIDINGWINDOW:4:15 MINLEN:36
