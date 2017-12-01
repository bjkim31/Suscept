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
        plink --bfile <:Path and prefix of binary plink:> --recode --out <:outfile:>
```

## Make l-mer profiles

```
        FIP -l [:l-mer:] -f [:g1k.TRAIN.list:] [:g1k.TEST.list:] > <output file: e.g) snps.l<l-mer>.tmp>
```

l, l-mer     : numeric value for length of SNP-Syntax
f, file-list : list of individual ids to profile 

the program FIP read ped file and convert it to number format genotypes. to understand the output filem please see [../doc/fileformat/snps.l.tmp](../doc/fileformat/snps.l.tmp)

[ Algorithm ]

[ 1 ]. Read IID/FAMILY file
[ 2 ]. Read every SNPs and convert it to numbers.
	- Rabin-Karp hash was introduced to reduce the
	  e.g) AA=>0 ; AC/CA => 1 ;
	- 
[ 3 ]. 
[ 4 ]. 
[ 5 ]. 
[ 6 ].

```

```

## Results


	
