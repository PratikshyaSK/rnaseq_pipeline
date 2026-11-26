
# Drosophila melanogaster RNA-seq Analysis

## 1. Project Overview

This project documents a practical RNA-seq data analysis workflow using a publicly available RNA-sequencing dataset from *Drosophila melanogaster* (fruit fly).

The analysis was performed to understand the basic steps involved in RNA-seq data processing, particularly reference genome alignment and gene-level read quantification.

The workflow includes working with paired-end sequencing data, quality assessment, read alignment using HISAT2, alignment file processing using SAMtools, and gene-level quantification using featureCounts.

This project was developed as a hands-on learning exercise to understand how raw sequencing reads are processed and used to generate gene-level read counts.

## 2. Dataset Information

- **Organism:** Drosophila melanogaster
- **GEO Sample Accession:** GSM461177
- **Sample Title:** S2_DRSC_Untreated-3
- **Source:** NCBI Gene Expression Omnibus (GEO)
- **Study Accession:** GSE18508
- **Sample Type:** RNA sequencing (RNA-seq)
- **Biological Material:** S2-DRSC cell line
- **Treatment:** Untreated
- **Library Strategy:** RNA-Seq
- **Sequencing Type:** Paired-end
- **Sequencing Platform:** Illumina Genome Analyzer II

### Dataset Source

The dataset was originally deposited in the NCBI Gene Expression Omnibus (GEO). The associated raw sequencing data are available through the NCBI Sequence Read Archive (SRA).

- GEO sample: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461177
- GEO study: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE18508

Galaxy was used as the analysis environment for working with the RNA-seq dataset.

## 3. Biological Background

*Drosophila melanogaster*, commonly known as the fruit fly, is an important model organism in genetics, molecular biology, and developmental biology.

The GSM461177 sample represents an untreated S2-DRSC cell-line sample. S2 cells are derived from Drosophila and are widely used in molecular and cellular biology research.

RNA sequencing provides information about the RNA molecules present in a biological sample. By analysing sequencing reads and assigning them to annotated genes, we can obtain gene-level read counts that can be used in downstream gene expression analyses.



## 4. Reference Genome and Gene Annotation

For RNA-seq alignment and gene-level quantification, a reference genome and its corresponding gene annotation file are required.

### 4.1 Reference Genome

- **File:** `dm6.fa`
- **Organism:** Drosophila melanogaster
- **Genome assembly:** dm6
- **Format:** FASTA

The reference genome contains the DNA sequences of the organism, organized into chromosomes and other genomic sequences.

In this project, the reference genome was used as the reference sequence for HISAT2 alignment. The sequencing reads were mapped against this genome to identify their possible genomic locations.

### 4.2 Gene Annotation

- **File:** `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf`
- **Format:** GTF (Gene Transfer Format)
- **Genome annotation release:** Ensembl release 109

The GTF file contains information about genomic features, including genes, transcripts and exons.

It provides genomic coordinates that help identify the locations and structures of annotated genes.

This annotation file was used by featureCounts to assign aligned sequencing reads to their corresponding genes.

### 4.3 Role of Reference Files in This Workflow

The reference genome and annotation file have different but complementary roles:

- The FASTA file provides the genomic sequence used for read alignment.
- The GTF file provides gene and exon information used for gene-level read counting.

Both files must correspond to compatible genome assemblies so that genomic coordinates and sequence names match correctly.


## 5. RNA-seq Data Retrieval and Preprocessing

### 5.1 Data Retrieval

The RNA-seq dataset GSM461177 was obtained from the NCBI Gene Expression Omnibus (GEO).

The corresponding raw sequencing data were retrieved through the NCBI Sequence Read Archive (SRA).

The dataset contains paired-end RNA-seq reads generated using an Illumina sequencing platform.

The downloaded sequencing reads were stored in FASTQ format for subsequent quality assessment and preprocessing.

### 5.2 Understanding FASTQ Files

FASTQ is a standard file format used to store raw sequencing reads together with their associated quality scores.

Each FASTQ record contains four lines:

1. Sequence identifier: identifies the sequencing read.
2. Nucleotide sequence: contains the A, T, G and C bases.
3. Separator line: separates the sequence from its quality information.
4. Quality scores: represent the estimated quality of each base.

### 5.3 Paired-End Sequencing

In paired-end sequencing, both ends of a DNA-derived fragment are sequenced, producing two corresponding read files:

- R1: Forward reads
- R2: Reverse reads

The paired reads provide information about the same original fragment and help improve read alignment.

### 5.4 Quality Assessment

FastQC was used to assess the quality of sequencing reads.

Quality assessment helps identify potential issues such as:

- Per-base sequence quality
- Sequence quality distribution
- GC content
- Adapter contamination
- Sequence duplication levels
- Overrepresented sequences

### 5.5 Read Trimming

Trimmomatic was used for read preprocessing to remove adapter contamination and low-quality bases.

The purpose of trimming is to improve the quality of reads before reference genome alignment.

The paired-end output files were retained for downstream alignment using HISAT2.


## 6. RNA-seq Read Alignment Using HISAT2

HISAT2 (Hierarchical Indexing for Spliced Alignment of Transcripts) is a fast and splice-aware aligner used to map RNA-seq reads against a reference genome.

Unlike genomic DNA sequencing, RNA-seq reads may span exon-exon junctions because introns are removed during RNA processing. HISAT2 can identify these splice junctions and align reads across exon boundaries.

### Alignment Workflow

1. A HISAT2 index was prepared using the Drosophila reference genome.
2. Paired-end FASTQ files (R1 and R2) were supplied as input.
3. HISAT2 aligned the reads against the reference genome.
4. Alignment statistics were generated to assess mapping performance.

The alignment produced a SAM (Sequence Alignment/Map) file containing information about the genomic positions and alignment characteristics of the reads.

## 7. SAM and BAM Processing Using SAMtools

SAMtools was used to process the alignment output generated by HISAT2.

The main processing steps included:

- **SAM to BAM conversion:** Converted the text-based SAM alignment file into the compressed binary BAM format.
- **BAM sorting:** Arranged aligned reads according to their genomic coordinates.
- **BAM indexing:** Created an index file to allow efficient access to specific genomic regions.

The sorted BAM file was subsequently used for gene-level read quantification.

## 8. Gene-Level Read Quantification Using featureCounts

featureCounts was used to assign aligned RNA-seq reads to annotated genes using the reference GTF annotation file.

The tool identifies overlaps between aligned reads and annotated genomic features and generates a gene-level read count table.

The resulting count file contains information such as:

- Gene identifiers
- Chromosome or sequence names
- Genomic start and end positions
- Strand information
- Gene length
- Assigned read counts

These gene-level counts provide the basis for downstream gene expression analysis.

## 9. Tools and Software Used

| Tool | Purpose |
|---|---|
| NCBI GEO | Public RNA-seq dataset information |
| NCBI SRA | Raw sequencing data repository |
| Galaxy | Web-based bioinformatics analysis platform |
| FastQC | Sequencing quality assessment |
| Trimmomatic | Read trimming and preprocessing |
| HISAT2 | Splice-aware read alignment |
| SAMtools | SAM/BAM processing |
| featureCounts | Gene-level read quantification |
| Linux Bash | Command-line operations |

## 10. Project Outputs

The main outputs generated during this analysis include:

- Quality control reports
- Trimmed paired-end FASTQ files
- HISAT2 alignment output
- Sorted and indexed BAM files
- Alignment statistics
- Gene-level read count table

Selected summary results and the analysis script are included in this repository.

## 11. Learning Outcomes

Through this project, I gained practical experience in:

- Understanding RNA-seq data and FASTQ file structure.
- Working with paired-end sequencing reads.
- Assessing sequencing quality and performing read preprocessing.
- Understanding reference genomes and gene annotation files.
- Performing splice-aware alignment using HISAT2.
- Converting, sorting and indexing alignment files using SAMtools.
- Understanding gene-level read quantification using featureCounts.
- Working with Linux commands and Bash scripts for bioinformatics workflows.

## 12. Future Scope

The gene-level read count output can be used for further downstream analysis, including count normalization, exploratory data analysis and differential gene expression analysis using tools such as DESeq2.
