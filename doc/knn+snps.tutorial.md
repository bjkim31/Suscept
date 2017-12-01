# Tutorial for kNN+SNP-Ss pipeline

# Author

BJ Kim (airbj31@yonsei.ac.kr or airbj31@berkeley.edu)

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
      - [parameter optimization](#parameter optimization)
      - contingency table
  - [Testing](#Testing)


# Procedure

The data for the tutorial is located in [../toy](../toy) directory.

Here are short descriptions of the files

**Data files**

- [g1k.affy6.chr22.bed](./toy/g1k.affy6.chr22.bed) - binary plink file of genotypes
- [g1k.affy6.chr22.fam](./toy/g1k.affy6.chr22.fam) - family relationship/phenotype file
- [g1k.affy6.chr22.bim](./toy/g1k.affy6.chr22.bim) - variant name/coordinate file for binary plink ped file.

- [g1k.TRAIN.list](./toy/g1k.TRAIN.list) - training files (equivalent for individual id in .fam file)
- [g1k.TEST.list](./toy/g1k.TEST.list)   - testing files  (equivalent for individual id in .fam file)

The sample data is generated from G1K .vcf files in [NCBI 1000 genome repository](ftp://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/release/20130502/) as follows.

  1. download the vcf files.

  2. remove INDEL variants by [vcftools](https://vcftools.github.io/)

  3. remove multipositional SNPs and some conflicts (different genotypes in same position)

  4. check if the whole data is biallelic.
  
  5. convert vcf file to plink binary file by plink.

  6. calculate kinship relationship by KING and remove some sample which having family relationship.

  7. extract SNPs on chromosome 22 and Affymetrix Genomewide human SNP array 6.0. 

The data contains 2457 samples and 11813 SNPs.

## Make plink ped file

We currently do not support binary .ped file. so you must transform it to non-binary plink files :


```
plink --bfile [:PATH/TO/g1k.affy6.chr22:] --recode --fam [:PATH/To/g1k.affy6.chr22.rename.fam:] --out [:new/PATH/TO/g1k-affy6-chr22:]

```
one important thing while conversion is the tag. we put first few letter for the class determination.

e.g) paste toy/g1k.affy6.chr22.fam toy/g1k.affy6.chr22.rename.fam

```

HG00096 HG00096 0 0 0 -9        EUR-HG00096 EUR-HG00096 0 0 0 -9
HG00097 HG00097 0 0 0 -9        EUR-HG00097 EUR-HG00097 0 0 0 -9
HG00099 HG00099 0 0 0 -9        EUR-HG00099 EUR-HG00099 0 0 0 -9
HG00100 HG00100 0 0 0 -9        EUR-HG00100 EUR-HG00100 0 0 0 -9
HG00101 HG00101 0 0 0 -9        EUR-HG00101 EUR-HG00101 0 0 0 -9
HG00102 HG00102 0 0 0 -9        EUR-HG00102 EUR-HG00102 0 0 0 -9
HG00103 HG00103 0 0 0 -9        EUR-HG00103 EUR-HG00103 0 0 0 -9
HG00105 HG00105 0 0 0 -9        EUR-HG00105 EUR-HG00105 0 0 0 -9
HG00106 HG00106 0 0 0 -9        EUR-HG00106 EUR-HG00106 0 0 0 -9
HG00107 HG00107 0 0 0 -9        EUR-HG00107 EUR-HG00107 0 0 0 -9

```

"EUR" is tag for the sample's class, European. the length of the tag is an argument of [get_accuracy_k](../bin/get_accuracy_k) program. see more details in [perform kNN](#perform-kNN)

## Training

In this tutorial, we suppose followings 

- we are trying to classify super-population using g1k population.

- we run the analysis under `TS1` directory

- we try parameter optimization using l-mer (l) of 4,6 and 8 and 1,5 and 100% filtering (f).

- You already add [./bin](../bin) to your PATH

### Make l-mer profile

 FIP program create matrix of family id, individual id, and each SNP Syntaxes consists of index and genotype from non-binary plink .ped file.

 following code generate 4,6 and 8-mer length syntax profiles in the directory of 'TS1/knn+snps/l$l/snps.l$l.tmp'

 to understand the output file, please see [../doc/fileformat/snps.lx.tmp](../doc/fileformat/snps.lx.tmp)

```
for l in 4 6 8;
do
	mkdir -p TS1/knn+snps/l$l  # make directory for workspace.
       	FIP -l $l -f [:PATH/TO/g1k.TRAIN.list:] [:PATH/TO/g1k-affy6-chr22.ped:] > TS1/knn+snps/l$l/snps.l$l.tmp
done

```

If the command works well, it prints family ids and individual ids to STDERR as follows.

**STDERR**

```
1 : EUR-HG00097 EUR-HG00097
2 : EUR-HG00099 EUR-HG00099
3 : EUR-HG00101 EUR-HG00101
4 : EUR-HG00102 EUR-HG00102
5 : EUR-HG00103 EUR-HG00103
6 : EUR-HG00105 EUR-HG00105
7 : EUR-HG00108 EUR-HG00108
8 : EUR-HG00109 EUR-HG00109
9 : EUR-HG00111 EUR-HG00111

```

**Parameters for FIP**

  - l, l-mer     : numeric value for length of SNP Syntax

  - f, file-list : list of individual ids to profile

  - inputfile    : argument withoug flag. non-binary plink ped file.


### filtering 

Filtering is divided into 3 steps.

#### calculate frequency of SNP Syntaxes

```

for l in 4 6 8;
do
	fipmerge TS1/knn+snps/l$l/snps.l$.tmp > ./TS1/knn+snps/l$l/merged.snps.l$l.tmp  
done

```

where snps.l$l.tmp is output of FIP program. this program currently do not have STDERR output.

the outputs, [merged.snps.l$l.tmp](./fileformat/merged.snps.lx.tmp), are 2 column textfile containing SNP-Syntaxes and its frequency.

You can check first 10 lines of the output as follows :

```
head ./TS1/knn+snps/l8/merged.snps.l8.tmp

```
**merged.snps.l$l.tmp**
```
020132710       6.6666666666666664e-04
020132712       6.6666666666666664e-04
022112112       8.6666666666666663e-03
022112210       2.0000000000000000e-03
022112215       6.6666666666666664e-04
022112710       1.3333333333333333e-03
022112712       2.0000000000000000e-03
022112715       9.3333333333333341e-03
022117112       1.3333333333333333e-03
022131112       1.0000000000000000e-02

```
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

 the usage is `sort.sh [:DIR:] [:l-mer:] [:filtering:] [:list file:]` where [:DIR:] is workspace, [:l-mer:] is the length of syntax, filtering is the percentage of the filtering and list file is training list file, g1k.TRAIN.list. 

 the output is used for the SNP Syntax filtering from the SNP-Syntax profile, [snps.l$l.tmp](./fileformat/snps.l$l.tmp) 

 if you use another output PATH/name, $DIR/knn+snps/l$l/merged.snps.l$l.tmp,  in a prior step, you should edit sort.sh since sort.sh only read `[:DIR:]/knn+snps/l$l/f$f/merged.snps.l$l.tmp`

 if you do not have awk but have gawk, then change the awk in the `./bin/sort.sh` to gawk

output files are `TS1/knn+snps/l$l/f$f/snps.bk.list'. these files are one column text file containing SNP Syntax which passed the filter.

#### make filtered profile

We extract SNP Syntaxes and it's index in the 'TS1/knn+snps/l$l/f$f/snps.bk.list' from whole profile file, 'TS1/knn+snps/l$l/snps.l$l.tmp', using fipfilt program.


```
for l in 4 6 8;
do
	for f in 1 5 100;
	do
		mkdir -p TS1/knn+snps/l$l/f$f/profile
		fipfilt ./TS1/knn+snps/l$l/f$f/snps.bk.list ./TS1/knn+snps/l$l/snps.l$l.tmp ./TS1/knn+snps/l$l/f$f/profile $l
	done
done

```
fipfilt receives 4 arguments, 

```
 fipfilt <arg1> <arg2> <arg3> <arg4>

```
- <arg1> is the filtered syntax list file, snps.bk.list, 
- <arg2> is the syntax profile, TS1/knn+snps/l$l/snps.l$l.tmp, 
- <arg3> output directory. you should make it before running the code.
- <arg4> l-mer, length of SNP syntaxes

the outputs are two column, syntax and it's frequency, text file which willl save in the directory of third argument.

### distance calculation

#### JS divergence calculation

the original JS divergence calculation code is implemented from [ffp program](https://sourceforge.net/projects/ffp-phylogeny/) by GE sims et al ([PNAS, 2009](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2634796/). it is also implemented in recent genome tree of life for the fungi kingdom by JJ Choi and S.-H. KIM [PNAS, 2017](http://www.pnas.org/content/114/35/9391.full)

To run this code, you should install [inline::C](http://search.cpan.org/~tinita/Inline-C-0.78/lib/Inline/C.pod)) module from CPAN.  

```
 perl -MCPAN -e 'install Inline::C'

```

if you are not familiar with perl, I recommend to install [perlbrew](https://perlbrew.pl/)

compiling is automatically done if you run the perl script however you need BKsource directory for compiling


```
mkdir BKsource;
mkdir -p TS1/knn+snps/l$l/f$f/jsd

for l in 4 6 8;
do 
	for f in 1 5 100;
	do
		for name in $(cat [:PATH/TO/g1k.TRAIN.list:]);
		do 
				ffpjsd2014 -p 6 -f [:PATH/TO/g1k.TRAIN.list:] ./TS1/knn+snps/l$l/f$f/profile/$name.tmp -b -n > TS1/knn+snps/l$l/f$f/jsd/$name.jsd
		done
	done
done

```

where -p flag for the number of places under decimal point, -f for the list of profile. input file is the full path/file name/extension for individual profile.

the program's strategy to calculate divergence is avoiding duplicated caclulation. for example, if we calculate the JS divergence between sample A and B then we do not need the calculation betwee B and A. the program removes the samples one by one in the list until the given sample id, individual profile file, is reached and then calculate JS divergence between remaining samples and given samples by one vs all approach when the file list flag (-f) is given. when -o 


To avoid duplicated calculations, the program removes the samples in the list one by one until the given sample id is reached and then calculate JS divergence between remaining samples and given sample by one vs all aproach when list file floag( -f) is given. when -o option is given, the program calculate JS divergence without sample removal. so -o option used to calculate JS divergence in testing.

In training it's normal that the number of lines (=calculation) are 0 to n-1 where n is the total number of samples in the list.

**Example**
```
$ wc -l *.jsd | sort -k1g 
       0 SAS-HG04100.jsd
       1 SAS-HG04061.jsd
       2 SAS-NA20861.jsd
       3 SAS-HG02733.jsd
       4 SAS-HG04093.jsd
       5 SAS-HG02774.jsd
       6 SAS-HG04118.jsd

    .... ...............
    .... ...............
    .... ...............

    1495 AFR-HG02614.jsd
    1496 AFR-NA18501.jsd
    1497 AFR-NA19149.jsd
    1498 AFR-HG02895.jsd
    1499 AFR-NA19317.jsd
```
   


#### make matrix


```
for l in 4 6 8;
do 
	for f in 1 5 100;
	do
		cat TS1/knn+snps/l$l/f$f/jsd/* > TS1/knn+snps/l$l/f$f/snps.dist	
		jsd_mat_maker -f [:PATH/TO/g1k.TRAIN.list:] -m TS1/knn+snps/l$l/f$f/snps.dist -b -n > ./TS1/knn+snps/l$l/f$f/snps.jsd.tmp
	done
done

```

jsd_mat_maker is a program to make distance matrix from 3 column distance list file.

- -f is the list of files. two list is possible if you want n (first list) x m(second list) matrix when you use "," as seperator. 
- -m is 3 column list file which contains sample A, sample B, and JS divergence score.
- -n is given the output does not print sample names
- -a is given the output does not print number


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
			get_accuracy_k -i 3 -f [:PATH/TO/g1k.TRAIN.list:] -m TS1/knn+snps/l$l/f$f/snps.jsd.tmp -k $k -o opt/TS$DIR.l$lmer.f$freq.k$i.summary >> ./opt/TS$DIR.l$lmer.f$freq;		
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
    for the detailed file format, please see the description, [./fileformat/summary](./fileformat/summary), and example in [../toy/result/TS1.l8.f1.k30.summary](../toy/result/TS1.l8.f1.k30.summary)
    the example file is the output of l=8,f=1 and k=30

STDOUT is 3 column output with k, number of True prediction and Accuracy ([../toy/result/TS1.l8.f1](../toy/result/TS1.l8.f1)).
	
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
 
#### Contingency table

the data for contingency table is acquired by the code in 'perform kNN' section.

please see more details in the section.

## Testing


Testing is almostly same as training, but some arguments are different from training.

the parameters for testing are l=8,f=1 and k=30 since it shows the best performance in training result


```
# make profile of SNP Syntaxes

FIP.pl -f [:PATH/to/g1k.TEST.list:] -l 8 [:PATH/TO/g1k-affy6-chr22.ped:] > TS1/knn+snps/l8/test_.snps.l8.tmp  
	
# make filtered profile using training filtered syntax list

fipfilt.pl ./TS1/knn+snps/l8/f1/snps.bk.list ./TS1/knn+snps/l8/test_.snps.l8.tmp ./TS1/knn+snps/l8/f1/profile 8

# jsd calculation between training set and testing set


for name in $(cat [:PATH/TO/g1k.TEST.list:]);
do 
			ffpjsd2014 -p 6 -f [:PATH/TO/g1k.TRAIN.list:] ./TS1/knn+snps/l$l/f$f/profile/$name.tmp -o > TS1/knn+snps/l$l/f$f/jsd/$name.jsd
done
	
# merge the jsd output 
	
cat ./TS1/knn+snps/l8/f1/jsd/* > ./TS1/knn+snps/l8/f1/snps.dist

# make jsd divergence matrix
# the command generate  number of TEST samples x number of Train samples matrix

perl jsd_mat_maker3.pl -f [:PATH/TO/g1k.TEST.list],[:PATH/TO/g1k.TRAIN.list:] -m ./TS1/knn+snps/l8/f1/snps.dist -b -n > ./TS1/knn+snps/l8/f1/test_snps.jsd.tmp

# calculate testing accuracy

get_accuracy_k -i 3 -f [:PATH/TO/g1k.TEST.list],[:PATH/TO/g1k.TRAIN.list:] -m TS1/knn+snps/l8/f1/test_snps.jsd.tmp -k 30 -o opt/TEST_TS1.l8.f1.k30.result

```

**output**

```
#k	nTP     Accuracy
30      936     0.9781

```
- Testing accuracy is 97.81%.

for further analysis, we use R script. 

I'll introduce it as soon as possible
