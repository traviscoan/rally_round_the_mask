# Replication code and data for Boussalis, Coan, and Holman's "Rally 'round the mask"

## Installing dependencies

### Version of ``R`` 

The original analysis presented in the paper used R 4.2.2. If you are using a newer version of ``R``, you will need to install R 4.2.2 for this code to work out-of-the-box.

#### Mac OSX

**Mac** users can download R 4.2.2 using the following link:

https://cran.r-project.org/bin/macosx/base/R-4.2.2.pkg

#### Linux

**Ubuntu** users can follow the instructions here to add the necessary CRAN repository:

https://cran.r-projet.org/bin/linux/ubuntu/fullREADME.html

After adding the cran40 repository, you can check which version of R are available using the terminal:

```
apt policy r-base
```

And then install R 4.2.2 by referencing the version:

```
sudo apt-get install r-base=4.2.2.20221110-1.2004.0
```

### ``gfortran``

If you do not alreay have ``gfortran`` on your system, then you will need to install it prior to installing the required ``R`` packages. 

#### Mac OSX

On a **Mac**, the easiest way to do so is using [brew](https://brew.sh/) and installing via the terminal:

```
brew install gcc
```

You may also need to edit ``Makevars`` file to tell ``R`` the correct directory for locating ``ggfortra``. If you don't already have ``Makevars`` file, create an ``/.R``folder in your home directory and manually create the ``Makevars`` file:

```
mkdir ~/.R
touch ~/.R/Makevars
```

Next, update the your ``Makevars`` file like so:

```
FC = /opt/homebrew/Cellar/gcc/13.2.0/bin/gfortran
F77 = /opt/homebrew/Cellar/gcc/13.2.0/bin/gfortran
FLIBS = -L/opt/homebrew/Cellar/gcc/13.2.0/lib/gcc/13
```

Note that your version of gcc may be different (mine is 13.2.0).

#### Linux

Ubuntu users can follow the very helpful guide available [here] (https://fortran-lang.org/learn/os_setup/install_gfortran/).

### ``cmdstanr`` and ``CmdStan``

To speed up model fitting, our analysis uses``cmdstanr`` 0.5.3 and ``CmdStan`` 2.30.1. You will need to install these libraries to replicate the analysis in the paper. First, install ``cmdstanr`` 0.5.3. You can download version 0.5.3 from the ``stan-dev`` GitHub repo [here](https://github.com/stan-dev/cmdstanr/archive/refs/tags/v0.5.3.tar.gz), which we've also included in this repository for convenience (`cmdstanr-0.5.3.tar.gz`). Assuming that you've already changed the current working directory to the root for this repository (e.g., `cd absolute/path/on/your/system/rally_round_the_flag`), you can then install ``cmdstanr`` from source using:

```
install.packages('cmdstanr-0.5.3.tar.gz', repos=NULL, type='source')
```

Next, we can use ``cmdstanr`` to download and install the correct version of the ``CmdStan``. After entering the ``R`` console, type:

```
cmdstanr::install_cmdstan(version = "v2.30.1")
```

### ``renv``

This project uses the ``renv`` library to ensure that you are using the same versions of the various ``R`` libraries used in the original analysis. To initalize ``renv``, launch ``R`` in the terminal from the root directory of the repository, which will load the project environment. Next, restore the project library from the lockfile:

```
renv::restore()
```