# Rice RNA-seq Analysis Pipeline

## Project Overview

This project demonstrates a basic paired-end RNA-seq data analysis workflow using Linux command-line tools and Bash scripting.

The analysis uses rice RNA-seq data (SRA accession: `SRR31535891`) and includes quality control, adapter trimming, read alignment, and BAM file processing.

## Tools Used

- **Linux (Ubuntu/WSL):** Command-line environment
- **FastQC:** Quality assessment of raw and trimmed reads
- **Trimmomatic:** Adapter removal and quality trimming
- **HISAT2:** Alignment of paired-end reads to the rice reference genome
- **SAMtools:** SAM-to-BAM conversion, sorting, indexing, and alignment statistics
- **Bash:** Automation of the analysis workflow

## Workflow

### Step 1: Quality Control of Raw Reads
FastQC was used to assess the quality of the raw paired-end FASTQ files.

### Step 2: Read Trimming
Trimmomatic was used to remove adapter sequences and low-quality bases.

### Step 3: Quality Control of Trimmed Reads
FastQC was run again to evaluate the quality of the trimmed reads.

### Step 4: Read Alignment
HISAT2 was used to align the paired-end reads against the rice reference genome.

### Step 5: SAM to BAM Conversion
SAMtools was used to convert the SAM alignment file into BAM format.

### Step 6: BAM Sorting
The BAM file was sorted using SAMtools.

### Step 7: BAM Indexing
An index was generated for the sorted BAM file.

### Step 8: Alignment Statistics
SAMtools flagstat was used to generate alignment statistics.

## Repository Contents

- `rnaseq_pipeline.sh` – Bash script containing the RNA-seq analysis workflow.

## How to Run

Clone this repository:

```bash
git clone https://github.com/PratikshyaSK/rnaseq_pipeline.git
cd rnaseq_pipeline
```

Run the pipeline:

```bash
bash rnaseq_pipeline.sh
```

**Note:** The script requires the input FASTQ files, rice reference genome index, adapter file, and required software to be available at the paths configured in the script. Update these paths according to your system.

## Project Status

This is a hands-on bioinformatics learning project. The pipeline script has passed a Bash syntax check and is being developed and improved as I gain practical experience in RNA-seq analysis.
