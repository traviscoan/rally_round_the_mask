# Replication code and data for Boussalis, Coan, and Holman's "Rally 'round the mask"

## Installing dependencies

### Version of ``R`` 

The original analysis presented in the paper used R 4.2.2. **Mac** users can download R 4.2.2 using the following link:

https://cran.r-project.org/bin/macosx/base/R-4.2.2.pkg

**Ubuntu** users can follow the instructions here to add the necessary CRAN repository:

https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html

After adding the cran40 repository, you can check which version of R are available using the terminal:

```
> apt policy r-base
```

And then install R 4.2.2 by referencing the version:

```
> sudo apt-get install r-base=4.2.2.20221110-1.2004.0
```

### ``gfortran``

If you do not alreay have ``gfortran`` on your system, then you will need to install it prior to installing the necessary ``R`` packages. 

On a **Mac**, the easiest way to do so is using [brew](https://brew.sh/) and installing via the terminal:

```
> brew install gcc
```