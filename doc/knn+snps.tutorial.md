# Tutorial for kNN+SNP-Ss pipeline

I'm writing this document right now.

# Author

BJ Kim (airbj31@yonsei.ac.kr / airbj31@berkeley.edu)

# Table of Contents

- [tutorial for kNN+SNP-Ss pipeline](#Tutorial-for-kNN+SNP-Ss-pipeline)
- [Author](#Author)
- [Table of Contents](#Table-of-contents)
- [Procedure](#Procedure)
  - [Make plink ped file](#make-plink-ped-file)
  - [Training](#Training)
    - [Make l-mer profile](#make-l-mer-profile)
    - [Filtering](#filtering)
      - [calculate frequency of SNP Syntaxes](#calculate-frequency-of-SNP-Syntaxes)
      - [Make filtered Syntaxes list](#make-filtered-syntaxes-list)
      - [Make filtered profiles](#make-filtered-profile)  
    - [distance calculation](#distance-calculation)
      - [JS divergence calculation](#JS-divergence-calculation)
      - [make matrix](#make-matrix)
    - [perform kNN](#perform-kNN)
      - [get_accuracy_k]()
    - [Results](#Results)
      - [parameter optimization]()
      - [contingency table]()
  - [Testing](#Testing)


# Procedure

the data for the tutorial is located in [../toy](../toy) directory.

here are short descriptions for the files

Data files

- [g1k.affy6.chr22.bed](./toy/g1k.affy6.chr22.bed) - binary plink file for genotypes
- [g1k.affy6.chr22.fam](./toy/g1k.affy6.chr22.fam) - family relationship/phenotype file
- [g1k.affy6.chr22.bim](./toy/g1k.affy6.chr22.bim) - variants coordinates file.

- [g1k.TRAIN.list](./toy/g1k.TRAIN.list) - training files (equivalent for individual id in .fam file)
- [g1k.TEST.list](./toy/g1k.TEST.list)   - testing files  (equivalent for individual id in .fam file)

The sample data is generated from [G1K vcf files](ftp://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/release/20130502/).

  1. download the vcf files.

  2. removing INDEL variants by [vcftools](https://vcftools.github.io/)

  3. removing multipositional SNPs and some conflicts (different genotypes in same position)

  4. check if the whole data is biallelic.
  
  5. convert vcf file to plink binary file by plink.

  6. calculate kinship relationship by KING and remove some sample which having family relationship.

  7. extract SNPs which are on the Affymetrix Whole GenomeWide Scan 6 array. 

the data contains 2457 samples and 11813 SNPs.

## make plink ped file

We currently do not support binary ped file. so you must transform it to non-binary plink files :


```
plink --bfile [:PATH/TO/g1k.affy6.chr22:] --recode --fam [:PATH/To/g1k.affy6.chr22.rename.fam:] --out [:new/PATH/TO/g1k-affy6-chr22:]

```


## Training


in this tutorial, we suppose followings 

- we are trying to classify super-population using g1k population.

- we run the analysis under `TS1` directory

- we try parameter optimization using l-mer(l) of 4,6 and 8 and 1,5 and 100% filtering(f).

- You already add [./bin](../bin) to your PATH

### Make l-mer profile


 FIP program create matrix of family id, individual id, and each SNP Syntaxes consists of index and genotype from non-binary plink .ped file.

 following code generate 4,6 and 8-mer length syntax profiles in the directory of 'TS1/knn+snps/l$l/snps.l$l.tmp'

 to understand the output file, please see [../doc/fileformat/snps.lx.tmp](../doc/fileformat/snps.lx.tmp)

```
for l in 4 6 8;
do
	mkdir -p TS1/knn+snps/l[:l-mer:]  # make directory for workspace.
       	FIP -l $l -f [:PATH/TO/g1k.TRAIN.list:] [:PATH/TO/g1k-affy6-chr22.ped:] > TS1/knn+snps/l$l/snps.l$l.tmp>
done

```

- Parameters for FIP

  - l, l-mer     : numeric value for length of SNP Syntax

  - f, file-list : list of individual ids to profile

  - inputfile    : non-binary plink ped file. 


### filtering 


Filtering is divided into 3 steps.

#### calculate frequency of SNP Syntaxes

```

for l in 4 6 8;
do
	fipmerge TS1/knn+snps/l$l.tmp > ./TS1/knn+snps/l$l/merged.snps.l$l.tmp  
done

```

 the output is 2 column textfile containing SNP-Syntaxes and its frequency [./fileformat/merged.snps.lx.tmp]](./fileformat/merged.snps.lx.tmp)


#### make filtered SNP-Syntaxes list 

```
for l in 4 6 8;
do
	for f in 1 5 100;
	do
		sort.sh TS1 $l $f [:PATH/TO/g1k.TRAIN.list:]
	done
done

```

 sort.sh is simple 'awk' command which extract first column based on the value of the second column of `fipmerge`'s output. 

 the usage is `sort.sh [:DIR:] [:l-mer:] [:filtering:] [:list file:]'

 the output is used for the SNP-Syntax filtering from the SNP-Syntax profile ('snps.l[:l-mer:].tmp) 

 if you use another output name in prior step, you must change sort.sh to run the code since sort.sh oly read `[:DIR:]/knn+snps/l$l/f$f/merged.snps.l$l.tmp`


#### make filtered profile



```
for l in 4 6 8;
do
	for f in 1 5 100;
	do
		mkdir -p TS1/knn+snps/l$l/f$f/profile
		fipfilt ./TS1/knn+snps/$l/f$f/snps.bk.list ./TS1/knn+snps/l$l/snps.l$l.tmp ./TS1/knn+snps/l$l/f$f/profile $l
	done
done

```

### distance calculation


#### JS divergence calculation


```
mkdir BKsource;

for l in 4 6 8;
do 
	for f in 1 5 100;
	do
		for name in $(cat [:PATH/TO/g1k.TRAIN.list:]);
		do 
				ffpjsd2014 -p 6 -f $LIST ./TS1/knn+snps/l$l/f$f/profile/$name.tmp > TS1/knn+snps/l$l/f$f/jsd/$name.jsd
		done
done

```

JS Divergence is calculated simple C code implemented in `ffpjsd2014` 

compiling is automatically done if you run the perl script however you need BKsource directory. so please make BKsource. 



#### make matrix


```
for l in 4 6 8;
do 
	for f in 1 5 100;
	do
		cat TS1/knn+snps/l$l/f$f/jsd/* > TS1/knn+snps/l$l/f$f/snps.dist	

	done
done

```

### perform kNN

kNN clustering is performed by perl ([get_accuracy_k](../bin/get_accuracy_k)) or R ([helloKNN.R](../bin/hellokNN.R))

the R code is not used in this tutorial.

```
for l in 4 6 8;
do
	for f in 1 5 100;
	do
		for k in 1 5 10 20 30 40 50 60 70 80 90 100;
		do
			perl ~/devel/get_accuracy_k.pl -i 3 -f [:PATH/TO/g1k.TRAIN.list:] -m TS1/knn+snps/l$l/f$f/snps.jsd.tmp -k $k -o opt/TS$DIR.l$lmer.f$freq.k$i.summary >> ./opt/TS$DIR.l$lmer.f$freq;		
		done
	done
done

```

arguments


- i is the length of tag which denotes class of the sample. e.g) EUR for European.
 
- f is the training list. the order should be same as the matrix's order.

- k is the number of neighbor to judge the class.

- o [:output:] 
    summary output for contingency table. 
    for the detailed file format, please see the description, [./fileformat](./fileformat/summary), and example in [../toy/result/TS1.l8.f1.k30.summary](../toy/result/TS1.l8.f1.k30.summary)
    the example file is the output of l=8,f=1 and k=30

STDOUT is 3 column output with k, number of True prediction and Accuracy ([../toy/result/TS1.l8.f1](../toy/result/TS1.l8.f1).
	
#### Parameter Optimization


```
for l in 4 6 8; 
do 
	for f in 1 5 100; 
	do 
		awk -v l=$l -v f=$f 'BEGIN{OFS="\t"}{print l,f,$0}' TS1.l$l.f$f
	 done
done | sort -k5g

```
**output of the file**

```{output}
#l-mer  filt    k       nTP     Accuracy ## header is not shown in the analysis.
            ...
            ...
            ...
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


- best performance, 94.27%, is shown with the parameter of l=8,f=1 and k=30
 

## Testing


Testing is almostly same as training, but some arguments are different from training.

the parameter used is l=8,f=1 and k=30 since it shows the best performance.


```
# make profile of SNP Syntaxes

FIP.pl -f [:PATH/to/g1k.TEST.list:] -l 8 [:PATH/TO/g1k-affy6-chr22.ped:]  
	
# make filtered profile using training filtered syntax list

fipfilt.pl ./$DIR/knn+snps/l$l/f$f/snps.bk.list ./$DIR/knn+snps/l$l/test_$CASE''.snps.l$l.tmp ./$DIR/knn+snps/l$l/f$f/profile $l

# jsd calculation between training set and testing set


for l in 4 6 8;
do 
	for f in 1 5 100;
	do

		for name in $(cat $LIST);
		do 
			ffpjsd2014 -p 6 -f [:PATH/TO/g1k.TRAIN.list:] ./TS1/knn+snps/l$l/f$f/profile/$name.tmp -o > TS1/knn+snps/l$l/f$f/jsd/$name.jsd
		done
	done
done

	
# merge the jsd output 
	
cat ./TS1/knn+snps/l8/f1/jsd/* > ./TS1/knn+snps/l8/f1/snps.dist

# make jsd divergence matrix
# the command generate #TEST samples x #Train samples JS distance matrix

perl jsd_mat_maker3.pl -f $TESTLIST,$LIST -m ./TS$i/knn+snps/l$l/f$f/snps.dist -b -n > ./TS$i/knn+snps/l$l/f$f/test_snps.$tst.jsd.tmp


# calculate testing accuracy

get_accuracy_k -i 3 -f [:PATH/TO/g1k.TEST.list],[:PATH/TO/g1k.TRAIN.list:] -m TS1/knn+snps/l8/f1/test_snps.jsd.tmp -k 30 -o opt/TS$DIR.l8.f1.k30.result

```

**output**

```
#k	nTP     Accuracy
30      936     0.9781

```
- Testing accuracy is 97.81%.

for further analysis, we use R script. 

I'll introduce it as soon as possible
