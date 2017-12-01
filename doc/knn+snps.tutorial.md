# Tutorial for program Usage

# Author

BJ Kim (airbj31@yonsei.ac.kr / airbj31@berkeley.edu)

# Table of Contents

- [tutorial for program Usage](#Tutorial-for-program-usage)
- [Author](#Author)
- [Table of Contents](#Table-of-contents)
- [Procedure](#Procedure)
  - [make plink ped file](#make-plink-ped-file)
  - [make l-mer profiles](#make-l-mer-profile)
  - [filtering](#filtering)
  - [make filtered profiles](#make-filtered-profile)  
  - [distance calculation](#distance calculation)
    - [JS divergence score calculation](#JS divergence score calculation)
    - [make matrix](#make-matrix)
  - [perform kNN]
    - [get_accuracy_k.pl]()
    - [helloKNN.R]()
  - [Results](#Results)
    - [parameter optimization]()
    - [training-and-testing]()
    - [contingency table]()
- [TL;DR script](#TL;DR)
    -
    -

# Procedure

the data for the tutorial is located in [../toy](../toy) directory.

here are short descriptions for the files

Data files

- [g1k.affy6.chr22.bed](./toy/g1k.affy6.chr22.bed) - binary plink file for genotypes
- [g1k.affy6.chr22.fam](./toy/g1k.affy6.chr22.fam) - family relationship/phenotype file
- [g1k.affy6.chr22.bim](./toy/g1k.affy6.chr22.bim) - variants coordinates file.

- [g1k.TRAIN.list](./toy/g1k.TRAIN.list) - training files (equivalent for individual id in .fam file)
- [g1k.TEST.list](./toy/g1k.TEST.list)   - testing files  (equivalent for individual id in .fam file)

The sample data is generated from [G1K vcf files]() located in the ncbi repository.

  1. download the vcf files.

  2. removing INDEL variants by [vcftools]()

  3. removing multipositional SNPs and some conflicts (different genotypes in same position)

  4. check if the whole data is biallelic.
  
  5. convert vcf file to plink binary file by plink.

  6. calculate kinship relationship by KING and remove some sample which having family relationship.

  7. extract SNPs which are on the Affymetrix Whole GenomeWide Scan 6 array. 

the data contains 2457 samples and 11813 SNPs.

## make plink ped file

We currently do not support binary ped file. so you must transform it to non-binary plink files :

```
        plink --bfile [:g1k.affy6.chr22:] --recode --fam [:g1k.affy6.chr22.rename.fam:] --out [:g1k-affy6-chr22:]
```

## Make l-mer profiles

```
	mkdir -p TS1/knn+snps/l[:l-mer:] # make directory for workspace.
        FIP -l [:l-mer:] -f [:g1k.TRAIN.list:] [:g1k-affy6-chr22.ped:] > TS1/knn+snps/l<l-mer>/snps.l[:l-mer].tmp>
```

- Parameters for FIP

l, l-mer     : numeric value for length of SNP-Syntax
f, file-list : list of individual ids to profile 

the program 'FIP' read ped file and convert it to number format genotypes. to understand the output file, please see [../doc/fileformat/snps.l.tmp](../doc/fileformat/snps.l.tmp)


## filtering 

Filtering is divided into 3 step.

  1. calculate the proportion of SNP-Syntaxes

```
	fipmerge 

```

 the output is 2 column textfile containing SNP-Syntaxes and its proportion (percentage)


  2. make filtered SNP-Syntaxes list 

```
	sort.sh

```

 sort.sh is simple 'awk' command which extract first column based on the value of the second column of `fipmerge`'s output. the output is used for the SNP-Syntax filtering from the SNP-Syntax profile ('snps.l[:l-mer:].tmp) 

  3. make filtered profile

```
	


```


	
