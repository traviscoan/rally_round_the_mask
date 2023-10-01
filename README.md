# Replication code and data for Boussalis, Coan, and Holman's "Rally 'round the mask"

## Installing dependencies

### Version of ``R`` 

The original analysis presented in the paper used ``R`` 4.2.2. While we provide instructions below on how to download and install ``R`` 4.2.2. on Mac and Ubuntu, newer versions of ``R`` should also work (**note**: we were able to the analysis described belwo using ``R`` 4.3.1).

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

Ubuntu users can follow the very helpful guide available [here](https://fortran-lang.org/learn/os_setup/install_gfortran/).

### ``renv``

This project uses the ``renv`` library to ensure that you are using the same versions of the various ``R`` libraries used in the original analysis. To initalize ``renv``, launch the ``R`` console from the project's root directory, which will load the project environment. Next, restore the project library from the lockfile:

```
renv::restore()
```

### ``cmdstanr`` and ``CmdStan``

To speed up model fitting, our analysis uses``cmdstanr`` 0.5.3 and ``CmdStan`` 2.30.1. You will need to install these libraries and versions to replicate the analysis in the paper. First, install ``cmdstanr`` 0.5.3. You can download version 0.5.3 from the ``stan-dev`` GitHub repo [here](https://github.com/stan-dev/cmdstanr/archive/refs/tags/v0.5.3.tar.gz), which we've also included in this repository for convenience (`cmdstanr-0.5.3.tar.gz`). Assuming that you've already changed the current working directory to the root for this repository (e.g., `cd absolute/path/on/your/system/rally_round_the_flag`), you can then install ``cmdstanr`` from source using:

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

**Note**: You might recieve deprecation warning related to std::sprintf when compiling Stan for the first time. You can safetly ignore this, as it's just saying that one of the functions used by the Boost c++ library has been marked as deprecated.

### Note on setting the random seed

Despite setting a random seed (in our ``R`` session and passing a ``seed`` to the ``brm`` function) and following suggestions to facilitate reproduceability when fitting threaded models via ``brms`` (e.g., estimating a single chain, setting the ``static`` argument to true in the ``threading()`` function), there will still be some randomness across runs due to multi-threading. As such, your results may differ slightly from the those presented in the paper.

### Sourcing scripts in the order presented in the paper

To recreate the analysis presented in the paper, you can `source()` the scripts via the ``R`` console in the following order:

1. Generate "Figure 1: Patterns in posting masked images over time". Start by generating Figure 1 using the following:

```
source("./scripts/main_fig1.R")
```

This will create a `fg1.tiff` in the `figures/` directory.

2. Run the scripts to reproduce "Appendix E: Statistica Results Tables". These tables provide the underlying data for Figures 2-4 presented in the main text of the manuscript.

```
source("./scripts/appendix_E_combined_table1-4.R")
source("./scripts/appendix_E_democrats_table5-8.R")
source("./scripts/appendix_E_republicans_table9-12.R")
```

This will create ``appendix_E_table1.csv`` through ``appendix_E_table12.csv`` in the `tables/` directory.

3. Generate Figures 2 to 4 presented in the main text. These tables provide the underlying data for Figures 2-4 presented in the main text of the manuscript.

```
source("./scripts/main_fig2-4.R")
```

This will create ``fg2.tiff`` through ``fg4.tiff`` in the `figures/` director.

4. (Optional) You can generate the Table F.1 through F.6 in "Appendix F: Covariate Model by Chamber, Ac-
count, Platform" by running the following:

```
source("./scripts/appendix_F_tableF1.R")
source("./scripts/appendix_F_tableF2.R")
source("./scripts/appendix_F_tableF3.R")
source("./scripts/appendix_F_tableF4.R")
source("./scripts/appendix_F_tableF5.R")
source("./scripts/appendix_F_tableF6.R")
```

These scripts will produce ``appendix_F_tableF1.csv`` to ``appendix_F_tableF6.csv`` in the ``tables/`` directory.

4. (Optional) Lastly, you can generate the Table G.1 through G.6 in "Appendix H: Party Models by Chamber, Ac-
count, Platform" by running the following:

```
source("./scripts/appendix_H_tableH1.R")
source("./scripts/appendix_H_tableH2.R")
source("./scripts/appendix_H_tableH3.R")
source("./scripts/appendix_H_tableH4.R")
source("./scripts/appendix_H_tableH5.R")
source("./scripts/appendix_H_tableH6.R")
```

These scripts will produce ``appendix_H_tableH1.csv`` to ``appendix_H_tableH6.csv`` in the ``tables/`` directory.