This nextflow script takes paired end fastq.gz files and trims and assembles them with trimmomatic and SPAdes, respectively. 

# Nextflow script for trimming and assembling paired end fastq.gz files

#### This script trims fastq.gz files with trimmoatic and assembles them with SPAdes

##### Create conda environment with software
`conda env create -f hmwrk.yml'

##### Activate conda environment
'conda activate homework'

##### Run nextflow script
'nextflow run biol7210_nf_homework.nf --reads 'data/*_{R1,R2}.fastq.gz'
