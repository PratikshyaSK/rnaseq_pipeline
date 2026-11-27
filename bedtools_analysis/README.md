# BEDTools Analysis of Drosophila RNA-seq Data

## 1. Introduction

In this project, I used BEDTools to explore the relationship between RNA-seq read alignments and annotated exons in the *Drosophila melanogaster* reference genome.

I had already aligned my RNA-seq reads to the reference genome using HISAT2 and generated a sorted BAM file.

The main objective of this exercise was to understand how RNA-seq alignments overlap with annotated exons and how to identify the genes associated with those overlaps.

## 2. Software and Input Files

### Software used

- BEDTools v2.31.1
- SAMtools
- AWK
- Linux command-line tools

### Input files

| File | Description |
|---|---|
| `dm6.fa` | Drosophila reference genome |
| `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf` | Gene annotation file |
| `GSM461177_script_sorted.bam` | Sorted RNA-seq alignment file |

## 3. Understanding the GTF Annotation

First, I examined the GTF annotation file to understand how genes and exons are represented.

```bash
head reference/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf
```

A GTF file contains information about genomic features such as:

- Genes
- Transcripts
- Exons
- CDS
- Start codons

The GTF file has nine columns. The third column identifies the feature type, while the fourth and fifth columns represent its start and end positions.

I also learned that GTF coordinates are 1-based and inclusive.

## 4. Extracting Exon Records

I extracted only the exon records from the GTF annotation file using AWK.

```bash
awk '$3 == "exon"' reference/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf > reference/exons.gtf
```

Here, `$3 == "exon"` selects only the records where the third column contains the word `exon`.

The extracted records were saved in `exons.gtf`.

## 5. Converting GTF to BED Format

Next, I converted the exon GTF file into BED format.

```bash
cd reference

awk -F '\t' 'BEGIN{OFS="\t"} {match($9,/gene_name "[^"]+"/); name=substr($9,RSTART+11,RLENGTH-12); print $1,$4-1,$5,name,0,$7}' exons.gtf > exons.bed
```

The BED file contains six columns:

1. Chromosome
2. Start position
3. End position
4. Gene name
5. Score
6. Strand

I used `$4-1` because BED coordinates are 0-based, while GTF coordinates are 1-based.

The start position is reduced by one, while the end position remains unchanged.

The gene name was extracted from the ninth GTF column.

## 6. Finding RNA-seq Alignments Overlapping Exons

After preparing the exon BED file, I used BEDTools to identify RNA-seq alignments overlapping annotated exons.

I first returned to the project directory.

```bash
cd ~/rnaseq_pipeline
```

Then I ran:

```bash
bedtools intersect -abam alignment/GSM461177_script_sorted.bam -b reference/exons.bed -split > alignment/reads_overlapping_exons.bam
```

### Understanding the command

- `bedtools intersect`: Finds overlapping genomic intervals.
- `-abam`: Specifies the BAM file as input A.
- `-b`: Specifies the exon BED file as input B.
- `-split`: Handles spliced RNA-seq alignments by considering their aligned blocks separately.
- `>`: Saves the output in a new BAM file.

The output file contains alignments that overlap at least one annotated exon.

## 7. Counting Exon-overlapping Alignments

I used SAMtools to count the alignment records in the original BAM file.

```bash
cd alignment

samtools view -c GSM461177_script_sorted.bam
```

Result:

```text
2632616
```

Then I counted the alignment records in the exon-overlapping BAM file.

```bash
samtools view -c reads_overlapping_exons.bam
```

Result:

```text
2106006
```

Approximately 80% of the original BAM alignment records were present in the exon-overlapping output.

These numbers represent alignment records, not necessarily unique reads or read pairs.

## 8. Converting BAM Alignments to BED Format

Next, I converted the original sorted BAM file into BED format.

```bash
bedtools bamtobed -split -i GSM461177_script_sorted.bam > reads.bed
```

This conversion allowed me to work with the genomic coordinates of RNA-seq alignments in BED format.

Now I had two BED files:

- `reads.bed`: Genomic locations of RNA-seq alignments.
- `../reference/exons.bed`: Genomic locations of annotated exons and their gene names.

## 9. Identifying Which Genes Overlap RNA-seq Alignments

I used BEDTools intersect again to compare the two BED files.

```bash
bedtools intersect -a reads.bed -b ../reference/exons.bed -wa -wb > reads_exon_overlaps.txt
```

### Understanding the command

- `-a reads.bed`: Contains RNA-seq alignment locations.
- `-b ../reference/exons.bed`: Contains annotated exon locations.
- `-wa`: Reports the complete read record.
- `-wb`: Reports the complete matching exon record.

The output file contains information from both BED files.

The gene name is available in column 10 because the first six columns come from the read BED file and the next six come from the exon BED file.

I inspected the results using:

```bash
head reads_exon_overlaps.txt
```

This helped me understand how individual RNA-seq alignments overlap annotated exons belonging to particular genes.

## 10. Identifying Unique Gene Names

I extracted gene names from column 10 and removed duplicate entries.

```bash
cut -f10 reads_exon_overlaps.txt | sort -u | wc -l
```

The result was:

```text
9625
```

This count included an empty gene-name entry. Therefore, it should not be interpreted as the exact number of uniquely named genes.

## 11. Summarizing Overlaps by Gene

I counted how many overlap records were associated with each gene.

```bash
cut -f10 reads_exon_overlaps.txt | sort | uniq -c | sort -nr > gene_overlap_counts.txt
```

The command:

- Extracted gene names from column 10.
- Sorted identical names together.
- Counted their occurrences using `uniq -c`.
- Sorted the results from highest to lowest count.

I inspected the output:

```bash
head gene_overlap_counts.txt
```

Some records had empty gene-name fields. The initial summary showed 415,563 overlap records without a gene name.

To exclude these empty entries, I generated a corrected summary:

```bash
awk -F '\t' '$10 != "" {print $10}' reads_exon_overlaps.txt | sort | uniq -c | sort -nr > gene_overlap_counts_named.txt
```

I inspected the corrected results using:

```bash
head gene_overlap_counts_named.txt
```

The corrected file contains overlap counts for records with non-empty gene names.

## 12. Results and Interpretation

The main results from this exercise were:

| Analysis | Result |
|---|---:|
| Original BAM alignment records | 2,632,616 |
| Exon-overlapping BAM alignment records | 2,106,006 |
| Approximate proportion overlapping exons | 80% |
| Unique column-10 values before excluding empty names | 9,625 |
| Overlap records with empty gene names | 415,563 |

The overlap summary helped identify genes associated with the RNA-seq alignments.

However, these values are read–exon overlap record counts, not definitive gene expression counts.

A read can overlap multiple annotated exon records, especially when different transcript isoforms share genomic regions. Therefore, the same read may appear more than once in the overlap results.

## 13. Conclusion

Through this exercise, I learned how to use BEDTools to compare RNA-seq alignments with annotated genomic features.

I practiced:

- Understanding GTF annotation files.
- Extracting exon records using AWK.
- Converting GTF coordinates into BED format.
- Converting BAM alignments into BED format.
- Finding overlapping genomic intervals using `bedtools intersect`.
- Counting exon-overlapping alignment records using SAMtools.
- Identifying gene names associated with overlapping exons.
- Summarizing overlap records by gene.
- Handling records with missing gene names.

This exercise helped me understand how genomic coordinates connect RNA-seq alignments to annotated genes.

**Note:** BEDTools was used here for genomic overlap analysis. For gene-level expression quantification, I used featureCounts in the RNA-seq workflow.

---

**Tools:** Linux | AWK | BEDTools | SAMtools | RNA-seq | Drosophila melanogaster
