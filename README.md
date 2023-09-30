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

You may also need to edit ``Makevars`` file to tell ``R`` the correct directory for locating ``ggfortran``. If you don't already have ``Makevars`` file, create an ``/.R``folder in your home directory and manually create the ``Makevars`` file:

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

### ``renv``

This project uses the ``renv`` library to ensure that you are using the same versions of the various ``R`` libraries used in the original analysis. To initalize ``renv``, launch the ``R`` console from the project's root directory, which will load the project environment. Next, restore the project library from the lockfile:

```
renv::restore()
```

### ``cmdstanr`` and ``CmdStan``

To speed up model fitting, our analysis uses``cmdstanr`` 0.5.3 and ``CmdStan`` 2.30.1. You will need to install these libraries to replicate the analysis in the paper. First, install ``cmdstanr`` 0.5.3. You can download version 0.5.3 from the ``stan-dev`` GitHub repo [here](https://github.com/stan-dev/cmdstanr/archive/refs/tags/v0.5.3.tar.gz), which we've also included in this repository for convenience (`cmdstanr-0.5.3.tar.gz`). Assuming that you've already changed the current working directory to the root for this repository (e.g., `cd absolute/path/on/your/system/rally_round_the_flag`), you can then install ``cmdstanr`` from source using:

```
# Get cmdstanr v0.5.3 directly from stan-dev using curl. You can also skip this step and install from the version included with the repository.
install.packages("curl")
curl::curl_download(url = "https://github.com/stan-dev/cmdstanr/archive/refs/tags/v0.5.3.tar.gz", destfile = "cmdstanr-0.5.3.tar.gz", mode="wb")
# Install cmdstanr from source
install.packages("data.table") # install data.table dependency
install.packages("cmdstanr-0.5.3.tar.gz", repos=NULL, type="source")
```

Next, we can use ``cmdstanr`` to download and install the correct version of the ``CmdStan``. After entering the ``R`` console, type:

```
cmdstanr::install_cmdstan(version = "2.30.1")
```

## Running the replication `/scripts`

The easiest way to run the various replication scripts located in the `/scripts` directory is to source them directly from the ``R`` console. For example to replicate Tables 1 though 4 in Appendix E, you can type the following from the console:

```
source('./scripts/appendix_E_combined_table1-4.R')
```

After the script finishes, you can find the model results for each table in the `/tables` directory. For instance, running the `appendix_E_combined_table1-4.R` produces the following CSV files in `/tables`: `appendix_E_table1.csv`, `appendix_E_table2.csv`, `appendix_E_table3.csv`, `appendix_E_table4.csv`.