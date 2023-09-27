# Replication file for the statistical analysis presented in Boussalis,
# Coan, Holman (2023) -- Appendix Table F.6: Twitter""

library(dplyr)
library(brms) # Easy way to estimate hierarchical zero-inflated beta model
library(ggplot2)
library(posterior)
library(emmeans)

# ---------------------------------------------------------------------------
# Pre-processing

set.seed(42)

# CHANGE to root directory for the replication data. Note that the if
# running the code via RScript, the system() function can be used to
# set the correct directory on Linux and Mac. Windows users may need to
# set the working directory manually.
setwd(system("pwd", intern = TRUE))

# Load data
data <- read.csv("data/data_twitter.csv")

# Load variable labels
labels <- read.csv("data/labels.csv")

# Define important weeks
week_cdc <- "2020_13,"   # CDC mask recommendation
week_biden <- "2020_21," # Biden appears in mask
week_trump <- "2020_28," # Trump appears in mask
week_elect <- "2020_44," # Election


###################################
# Fit model

# Weakly informative priors
bprior <- c(
  prior("student_t(3,0,2.5)", class = "b"),
  prior("student_t(3,0,2.5)", class = "Intercept"),
  prior("student_t(3,0,2.5)", class = "b", dpar = "zi"),
  prior("student_t(3,0,2.5)", class = "Intercept", dpar = "zi")
)

# Instantiate formula for brms
bformula <- bf(
  mask_prop_rescale ~ 1 + scale(nokken_poole_dim1) +  scale(nokken_poole_dim2) + scale(net_trump_vote) + scale(margin_pc) + gender + scale(age) + type + scale(cases_norm_l1) + scale(deaths_norm_l1) + mask_mandate + scale(dpres) + scale(medianIncomeE) + scale(age65_prop) + scale(Very.low.density) + scale(followers) + republican + independent + (1|bioguide) + (1|yr_wk),
  zi ~ 1 + scale(nokken_poole_dim1) +  scale(nokken_poole_dim2) + scale(net_trump_vote) + scale(margin_pc) + gender + scale(age) + type + scale(cases_norm_l1) + scale(deaths_norm_l1) + mask_mandate + scale(dpres) + scale(medianIncomeE) + scale(age65_prop) + scale(Very.low.density) + scale(followers) + republican + independent + (1|bioguide) + (1|yr_wk)
)

# Fit zero-inflated beta for members of the House
fit_all <- brm(formula = bformula,
           data = data,
           family = zero_inflated_beta(link = "logit"),
           prior = bprior,
           warmup = 2000,
           iter = 10000,
           chains = 1,
           backend = "cmdstanr",
           threads = threading(10, static = TRUE),
           control = list(adapt_delta = 0.95),
           thin = 2,
           seed = 42)


# Extract and summarize posterior
all_post <- as_draws_df(fit_all)
estimates <- summarise_draws(
    all_post,
    "mean",
    "median",
    "sd",
    ~quantile(.x, probs = c(0.025, 0.05, 0.95, 0.975))
    )

# Extract indices for important "events"
idx_cdc <- grep(week_cdc, estimates[[1]])
idx_biden <- grep(week_biden, estimates[[1]])
idx_trump <- grep(week_trump, estimates[[1]])
idx_elect <- grep(week_elect, estimates[[1]])

# Extract fixed factors, random effects for key events, and save
# data frame.
idx <- c(rep(1:36), idx_cdc, idx_biden, idx_trump, idx_elect)
estimates <- estimates[idx, ]

# Merge variable labels for readability
estimates_labels <- merge(estimates, labels, by = "variable", all.x = TRUE)

# Rename variables for plotting
names(estimates_labels) <- c(
  "variable", "post_mean", "post_median", "sd", "lower95",
  "lower90", "upper90", "upper95", "model", "label")

# Save estimates for future use
write.csv(estimates_labels, "tables/appendix_F_tableF6.csv", row.names = FALSE)
