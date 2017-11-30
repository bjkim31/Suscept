# Prediction of Inherited Susceptibility Using Machine Learning

BJ KIM

# Table of contents

- [Prediction of Inhertied Susceptibility using Machine Learning](#Prediction-of-Inherited-Susceptibility-Using-Machine-Learning)
- [Table of contents](#table-of-contents)
- [Introduction](#Introduction)
- [Installation](#Installation)
    - [Requirement](#Requirement)
    - [directory/file tree](#Directory-and-File-tree)
- [Tutorial/Procedure](#tutorial)

# Introduction

The original method is developed by MS KIM and S-H Kim [(PNAS, 2014)](http://www.pnas.org/content/111/5/1921.abstract) and *k*NN-Syntax script in the paper is rewritten by BJ KIM (not published yet.)

# Installation

Simply download the files or try following command in unix-like environemnt.

```
        git clone https://github.com/bjkim31/Suscept.git
```

## Requirement 

No installation required. but following programs/packages are required to run the pipeline

- [perl 5.8 or higher](https://www.perl.org/) and [Inline::C](http://search.cpan.org/~tinita/Inline-C-0.78/lib/Inline/C.pod) module 
    - note that Inline::C is required for JS divergence score
- [R](https://cran.r-project.org/) and [tidyr](https://cran.r-project.org/web/packages/tidyr/), [dplyr](https://cran.r-project.org/web/packages/dplyr/), [ggplot2](https://cran.r-project.org/web/packages/ggplot2/) packages 
- [awk/gawk](https://www.gnu.org/software/gawk/)
- [plink](https://www.cog-genomics.org/plink2)
- [open grid scheduler](http://gridscheduler.sourceforge.net/) (a.k.a :sun grid scheduler) is highly recommended for speed but not essential.

## Directory and File tree

- please see [filetree.txt](./doc/filetree.txt) for short description about the file and 

# Tutorial

- please see [./doc/tutorial.md](./doc/tutorial.md) for details
