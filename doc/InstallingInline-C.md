# Installing Inline::C using perlbrew

This guide is written for perl beginners who have a problem with installing perl-module

Fortunaelty, there is a `perlbrew` which is a tool to manage multiple perl installation and packages under your local $HOME folder.

So the perlbrew enables that

- You can use each perl installation independnetly regardless of the version.

- You can install perl without privilege.

- You can test your code in different version of perl.


for more information, please visit https://perlbrew.pl


# Perlbrew Installation


You can install perlbrew like follows


```
 curl -L https://install.perlbrew.pl | bash

# if you use Linux
 wget -O - https://install.perlbrew.pl | bash

# if you use FreeBSD
 fetch -o- https://install.perlbrew.pl | sh

```

the command generate followng output with installation.


```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170  100   170    0     0     25      0  0:00:06  0:00:06 --:--:--    40
100  1247  100  1247    0     0    169      0  0:00:07  0:00:07 --:--:-- 13126

## Download the latest perlbrew

## Installing perlbrew
perlbrew is installed: ~/perl5/perlbrew/bin/perlbrew

perlbrew root (~/perl5/perlbrew) is initialized.

Append the following piece of code to the end of your ~/.bash_profile and start a
new shell, perlbrew should be up and fully functional from there:

    source ~/perl5/perlbrew/etc/bashrc

Simply run `perlbrew` for usage details.

Happy brewing!

## Installing patchperl

## Done.
```

# add perlbrew environment into your .bashrc 


please add `source ~/perl5/perlbrew/etc/bashrc` to the end of `.bash_profile` or `.bashrc` or equivalent file.


# Initiate perlbrew


```
 perlbrew init

```

# check the available perl 

```
 perlbrew available

```

```
   perl5.005_04      URL: <http://www.cpan.org/src/5.0/perl5.005_04.tar.gz>
   perl5.004_05      URL: <http://www.cpan.org/src/5.0/perl5.004_05.tar.gz>
   perl-5.8.9        URL: <http://www.cpan.org/src/5.0/perl-5.8.9.tar.gz>
   perl-5.6.2        URL: <http://www.cpan.org/src/5.0/perl-5.6.2.tar.gz>
   perl-5.27.6       URL: <http://www.cpan.org/src/5.0/perl-5.27.6.tar.gz>
   perl-5.26.1       URL: <http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz>
   perl-5.24.3       URL: <http://www.cpan.org/src/5.0/perl-5.24.3.tar.gz>
   perl-5.22.4       URL: <http://www.cpan.org/src/5.0/perl-5.22.4.tar.gz>
   perl-5.20.3       URL: <http://www.cpan.org/src/5.0/perl-5.20.3.tar.gz>
   perl-5.18.4       URL: <http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz>
   perl-5.16.3       URL: <http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz>
   perl-5.14.4       URL: <http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz>
   perl-5.12.5       URL: <http://www.cpan.org/src/5.0/perl-5.12.5.tar.gz>
   perl-5.10.1       URL: <http://www.cpan.org/src/5.0/perl-5.10.1.tar.gz>
  cperl-5.27.1       URL: <https://github.com/perl11/cperl/archive/cperl-5.27.1.tar.gz>
  cperl-5.26.1-msvc      URL: <https://github.com/perl11/cperl/archive/cperl-5.26.1-msvc.tar.gz>

```

# install perl


```
 perlbrew install perl-5.22.4

```
$ perlbrew install perl-5.22.4

Fetching perl 5.22.4 as $HOME/perl5/perlbrew/dists/perl-5.22.4.tar.bz2
Download http://www.cpan.org/src/5.0/perl-5.22.4.tar.bz2 to $HOME/perl5/perlbrew/dists/perl-5.22.4.tar.bz2
Installing $HOME/perl5/perlbrew/build/perl-5.22.4 into ~/perl5/perlbrew/perls/perl-5.22.4

This could take a while. You can run the following command on another shell to track the status:

  tail -f ~/perl5/perlbrew/build.perl-5.22.4.log

perl-5.22.4 is successfully installed.

# see what you have.

```
 perlbrew list

```

```
  perl-5.22.4
* perl-<blah>.<blah>.<blah>

```

the \* symbol indicates that you use that version of perl and it's lib.


# use the perl in single terminal temporary

```
 perlbrew use perl-5.22.4

```

# make local library path

```
	perlbrew lib create <perl-version/library/name>

```

## use above library and version of perl permanently

```
	perlbrew list #check if the <library name> is existing
	perlbrew switch <perl-version/library/name>


```

## install cpanm

 cpanm is module management program.


```
	perlbrew install-cpanm 

```

## install Inline::C using cpanm


```
	cpanm Inline::C

```

## Done !

it's done

