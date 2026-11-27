o

#!/bin/bash

# BEDTools Analysis of Drosophila RNA-seq Data
# Author: Pratikshya Subedi

echo "Starting BEDTools Analysis"

echo "Step 1: Extracting exon records from GTF"

awk '$3 == "exon"' reference/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf > reference/exons.gtf

echo "Step 2: Converting GTF to BED format"

awk -F '\t' 'BEGIN{OFS="\t"} {match($9,/gene_name "[^"]+"/); name=substr($9,RSTART+11,RLENGTH-12); print $1,$4-1,$5,name,0,$7}' reference/exons.gtf > reference/exons.bed

echo "Step 3: Finding alignments overlapping exons"

bedtools intersect -abam alignment/GSM461177_script_sorted.bam -b reference/exons.bed -split > alignment/reads_overlapping_exons.bam

echo "Step 4: Counting exon-overlapping alignments"

samtools view -c alignment/GSM461177_script_sorted.bam

samtools view -c alignment/reads_overlapping_exons.bam

echo "Step 5: Converting BAM alignments to BED"

bedtools bamtobed -split -i alignment/GSM461177_script_sorted.bam > alignment/reads.bed

echo "Step 6: Identifying read-exon overlaps"

bedtools intersect -a alignment/reads.bed -b reference/exons.bed -wa -wb > alignment/reads_exon_overlaps.txt

echo "Step 7: Identifying unique gene names"

cut -f10 alignment/reads_exon_overlaps.txt | sort -u | wc -l

echo "Step 8: Counting overlap records for each gene"

cut -f10 alignment/reads_exon_overlaps.txt | sort | uniq -c | sort -nr > alignment/gene_overlap_counts.txt

echo "Step 9: Excluding empty gene names"

awk -F '\t' '$10 != "" {print $10}' alignment/reads_exon_overlaps.txt | sort | uniq -c | sort -nr > alignment/gene_overlap_counts_named.txt

echo "BEDTools analysis completed!"
