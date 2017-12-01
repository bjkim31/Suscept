# Tutorial for kNN+SNPS-S pipeline

I'm writing this document right now.

# Author

BJ Kim (airbj31@yonsei.ac.kr / airbj31@berkeley.edu)

# Table of Contents

- [tutorial for program Usage](#Tutorial-for-program-usage)
- [Author](#Author)
- [Table of Contents](#Table-of-contents)
- [Procedure](#Procedure)
  - [Make plink ped file](#make-plink-ped-file)
  - [Make l-mer profiles](#make-l-mer-profile)
  - [Filtering](#filtering)
    - 1. [Make ]
    - 2. [Make filtered Syntaxes list](#make-filtered-syntaxes-list)
    - 3. [Make filtered profiles](#make-filtered-profile)  
  - [distance calculation](#distance-calculation)
    - [JS divergence calculation](#JS-divergence-calculation)
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
        FIP -l [:l-mer:] -f [:g1k.TRAIN.list:] [:g1k-affy6-chr22.ped:] > TS1/knn+snps/l[:l-mer:]/snps.l[:l-mer].tmp>
```

- Parameters for FIP

  - l, l-mer     : numeric value for length of SNP Syntax

  - f, file-list : list of individual ids to profile

  - inputfile    : non-binary plink ped file. 

the program 'FIP' read ped file and convert it to number format genotypes. to understand the output file, please see [../doc/fileformat/snps.lx.tmp](../doc/fileformat/snps.lx.tmp)


## filtering 

Filtering is divided into 3 steps.

  1. calculate the proportion of SNP-Syntaxes

```
	fipmerge TS1/knn+snps/l[:l-mer:].tmp > ./TS1/knn+snps/l[:l-mer:]/merged.snps.l[:l-mer:].tmp  

```

 the output is 2 column textfile containing SNP-Syntaxes and its proportion (percentage)


  2. make filtered SNP-Syntaxes list 

```
	sort.sh [:dir:] [:l-mer:] [:LIST:]

```

 sort.sh is simple 'awk' command which extract first column based on the value of the second column of `fipmerge`'s output. the output is used for the SNP-Syntax filtering from the SNP-Syntax profile ('snps.l[:l-mer:].tmp) 

  3. make filtered profile


```
	mkdir -p TS1/knn+snps/l[:l-mer:]/f[:filter:]/profile
	fipfilt ./$DIR/knn+snps/l[:l-mer:]/f[:filter:]/snps.bk.list ./TS1/knn+snps/l[:l-mer:]/snps.l$l.tmp ./TS1/knn+snps/l[:l-mer:]/f[:filter:]/profile [:l-mer:] 

```

## distance calculation


### JS divergence calculation


```
	for name in $(cat $LIST);
	do 
		ffpjsd2014 -p 6 -f $LIST ./$DIR/knn+snps/l$l/f$f/profile/$name.tmp > DIR/knn+snps/l[:l-mer:]/f[:filter:]/jsd/$name.jsd
	done

```

### make matrix


```
	cat TS1/knn+snps/l[:l-mer:]/f[:filter:]/jsd/* > TS1/knn+snps/l[:l-mer:]/f[:filter:]/snps.dist
	

```

# perform kNN


# Results
	
## Parameter Optimization


```
	for l in 4 6 8; 
	do 
		for f in 1 5 100; 
		do 
			awk -v l=$l -v f=$f 'BEGIN{OFS="\t"}{print l,f,$0}' TS1.l$l.f$f
		 done
	done | sort -k5g

```

```{output}
#l      f       k       nTP     Accuracy
6       5       10      1405    0.9367
6       5       5       1406    0.9373
8       1       50      1408    0.9387
8       5       10      1408    0.9387
8       1       20      1409    0.9393
6       1       30      1412    0.9413
8       1       40      1412    0.9413
8       5       5       1413    0.9420
8       1       30      1414    0.9427

```


- best performance is shown in l=8,f=1 and k=30
 

## Testing


Test is almostly same as training, but some arguments are different from training.


```
	# make profile of SNP Syntaxes
	
	# make filtered profile using training filtered syntax list

	# jsd calculation between training set and testing set

	# merge the jsd output 

	# make jsd divergence matrix


```


