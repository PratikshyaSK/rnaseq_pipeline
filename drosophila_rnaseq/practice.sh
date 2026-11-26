
#!/bin/bash

#Activate the conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate rna_seq


#####################Step 1: Running FastQC #########################

# Create a folder to store raw_fastq quality reports
mkdir -p fastqc_report

# Run FastQC on raw paired-end reads
echo "Running FastQC for SRA_ID=$SRA_ID"

fastqc "raw_fastq/GSM461177_1_subsampled.fastqsanger" \
       "raw_fastq/GSM461177_2_subsampled.fastqsanger" \
       -o fastqc_report/ \
       -t 4
echo "FastQC Completed for  $SRA_ID.Reports are saved in fastqc_report/"

####################Step 2:Running Trimmomatic to trim ##########################################

# Directory to store trimmed FASTQ files
TRIM_OUTDIR="/home/dell/rnaseq_pipeline/trimmed_fastq/"

# Adapter files
ADAPTER_PE="/home/dell/miniconda3/envs/rna_seq/share/trimmomatic-0.41-0/adapters/TruSeq3-PE.fa"

# Create a folder for trimmed FASTQ files
mkdir -p "$TRIM_OUTDIR"

# Run Trimmomatic
echo " Running trimmomatic..."

trimmomatic PE -threads 4 -phred33 \
  ~/rnaseq_pipeline/raw_fastq/GSM461177_1_subsampled.fastqsanger \
  ~/rnaseq_pipeline/raw_fastq/GSM461177_2_subsampled.fastqsanger \
  ~/rnaseq_pipeline/trimmed_fastq/GSM461177_1_paired.fastq.gz \
  ~/rnaseq_pipeline/trimmed_fastq/GSM461177_1_unpaired.fastq.gz \
  ~/rnaseq_pipeline/trimmed_fastq/GSM461177_2_paired.fastq.gz \
  ~/rnaseq_pipeline/trimmed_fastq/GSM461177_2_unpaired.fastq.gz \
  ILLUMINACLIP:/home/dell/miniconda3/envs/rna_seq/share/trimmomatic-0.41-0/adapters/TruSeq3-PE.fa:2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

echo"Trimmomatic finished successfully!"

##########################Step 3: Running FastQC on trimmed file #################################################################

#Path to trimmed file
# TRIM_OUTDIR is the path for trimmed file


TRIM_FASTQC_OUTDIR="/home/dell/rnaseq_pipeline/fastqc_trimmed/"

# Create a folder for fastqc trimmed files
 mkdir -p "$TRIM_FASTQC_OUTDIR"

# Run FastQC report

echo "Running FastQC for SRA ID=$SRA_ID"

fastqc "trimmed_fastq/GSM461177_1_paired.fastq.gz" \
       "trimmed_fastq/GSM461177_2_paired.fastq.gz" \
       -o "$TRIM_FASTQ_OUTDIR" \
       -t "$THREADS"

echo "FASTQC completed for $SRA_ID trimmed files. Reports are saved in $TRIM_FASTQC_OUTDIR" 


#####################Step 4: Run Hisat2 ##############################################################################################

# RNA-seq alignment pipeline
# HISAT2 to SAMtools stat

set -e

# Project directory
PROJECT_DIR="$HOME/rnaseq_pipeline"
cd "$PROJECT_DIR"

# Number of threads
THREADS=4

# Input paired-end FASTQ files
R1="trimmed_fastq/GSM461177_1_paired.fastq.gz"
R2="trimmed_fastq/GSM461177_2_paired.fastq.gz"


#Location of files
REF_GENOME="reference/dm6.fa"
GENOME_INDICES="reference/index_output"

# HISAT2 reference index
hisat2-build -p 4 \
$REF_GENOME \
$GENOME_INDICES 

# Output directory
OUTDIR="alignment"

# Create a folder 
mkdir -p "$OUTDIR"

echo "Running HISAT2 alignment for SRA ID...."

hisat2 \
-p "$THREADS" \
-x "$GENOME_INDICES" \
-1 "$R1" \
-2 "$R2" \
-S "$OUTDIR/GSM461177_script.sam"

echo "HISAT2 alignment completed!"

####################Step 5= Convert SAM to BAM ###############################################

echo "Converting SAM file to BAM format..."

samtools view \
-b \
-o "$OUTDIR/GSM461177_script.bam" \
"$OUTDIR/GSM461177_script.sam"

echo "SAM to BAM conversion completed!"


#######################Step 6= Sort Bam file #########################

echo "Sorting BAM file..."

samtools sort \
-@ "$THREADS" \
-o "$OUTDIR/GSM461177_script_sorted.bam" \
"$OUTDIR/GSM461177_script.bam"

echo "BAM sorting completed!"

##################### Step 7: Index sorted BAM file #####################

echo "Indexing sorted BAM file..."

samtools index \
"$OUTDIR/GSM461177_script_sorted.bam"

echo "BAM indexing completed!"

##################### Step 8: Alignment statistics #####################

echo "Generating alignment statistics..."

samtools flagstat \
"$OUTDIR/GSM461177_script_sorted.bam" \
> "$OUTDIR/GSM461177_script_flagstat.txt"

echo "RNA-seq alignment pipeline completed successfully!"

################# Step 9:featureCount  ##############################

echo "Starting gene-level read quantification using featureCounts..."

GTF_FILE="reference/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf"

featureCounts \
-a $GTF_FILE \
-o $OUTDIR/counts2.txt \
-p \
-Q 10 \
-T 4 \
"$OUTDIR/GSM461177_script_sorted.bam"

echo "featureCounts completed sucessfully.Gene count results saved in $OUTDIR/counts.txt"












