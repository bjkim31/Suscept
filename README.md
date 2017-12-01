# Prediction of Inherited Susceptibility Using Machine Learning

Author - BJ KIM (airbj31@yonsei.ac.kr or airbj31@berkeley.edu)

# Table of contents

- [Prediction of Inhertied Susceptibility using Machine Learning](#Prediction-of-Inherited-Susceptibility-Using-Machine-Learning)
- [Table of contents](#table-of-contents)
- [Introduction](#Introduction)
- [Installation](#Installation)
    - [Requirement](#Requirement)
    - [directory/file tree](#Directory-and-File-tree)
- [Tutorial/Procedure](#tutorial)
- [advanced usage](#advanced-usage)
- [TL;DR](#TL;DR)

# Introduction

The original method is developed by MS KIM and S.-H. Kim [(PNAS, 2014)](http://www.pnas.org/content/111/5/1921.abstract)
the *k*NN-Syntax script in the paper is rewritten by BJ KIM (not published yet.)

# Installation

Simply download the files or try following command in unix-like environemnt.


```

git clone https://github.com/bjkim31/Suscept.git


```

## Requirement 

No installation required. however following programs/packages are required to run the pipeline

*Essential*
- [perl 5.8 or higher](https://www.perl.org/) 
    - [Inline::C](http://search.cpan.org/~tinita/Inline-C-0.78/lib/Inline/C.pod) is required for JS divergence score
- [awk/gawk](https://www.gnu.org/software/gawk/)
- [plink](https://www.cog-genomics.org/plink2)

*Optional*
- [open grid scheduler](http://gridscheduler.sourceforge.net/) (a.k.a :sun grid scheduler) is highly recommended for speed but not essential.
- [R](https://cran.r-project.org/) - R is used for graphics or *k*NN classification after generating JS divergence score matrix
    - [tidyr](https://cran.r-project.org/web/packages/tidyr/)
    - [dplyr](https://cran.r-project.org/web/packages/dplyr/)
    - [ggplot2](https://cran.r-project.org/web/packages/ggplot2/) packages 

## Directory and File tree

- please see [./doc/filetree.txt](./doc/filetree.txt) for short description about the files in the repositry.

# Tutorial

- please see [./doc/knn+snps.tutorial.md](./doc/knn+snps.tutorial.md) for the procedure of kNN+SNP-Ss method 

# Advanced Usage

- not ready yet

# TL;DR script

- not ready yet
