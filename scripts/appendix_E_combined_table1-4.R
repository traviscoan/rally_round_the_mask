# Replication file for the statistical analysis presented in Boussalis,
# Coan, Holman (2023), Appendix E, Tables 1 - 3.

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
data <- read.csv("data/data.csv")

# Load variable labels
labels <- read.csv("data/labels.csv")

# Define important weeks
week_cdc <- "2020_13,"   # CDC mask recommendation
week_biden <- "2020_21," # Biden appears in mask
week_trump <- "2020_28," # Trump appears in mask
week_elect <- "2020_44," # Election

# ---------------------------------------------------------------------------
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

# Fit zero-inflated beta
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
estimates_labels <- merge(estimates, labels, by = "variable")

# ---------------------------------------------------------------------------
# Generate tables

# Split zero-inflated and beta coefficients
estimates_zi <- estimates_labels[grepl("_zi", estimates_labels$variable), ]
estimates_beta <- estimates_labels[!grepl("_zi", estimates_labels$variable), ]

# Seperate offsets
estimates_zi_offsets <- estimates_zi[grepl("offset", estimates_zi$label), ]
estimates_zi <- estimates_zi[!grepl("offset", estimates_zi$label), ]

estimates_beta_offsets <- estimates_beta[grepl("offset", estimates_beta$label), ]
estimates_beta <- estimates_beta[!grepl("offset", estimates_beta$label), ]

# Order covariates to match paper
order_of_variables <- c("Intercept",
               "Republican",
               "Independent",
               "Ideology (DW Nominate 1)",
               "Ideology (DW Nominate 2)",
               "Net Trump vote",
               "Senator",
               "Gender",
               "Age",
               "Cases",
               "Deaths",
               "State mask mandate",
               "Clinton vote share",
               "Margin of victory",
               "Median income",
               "Population density ",
               "Proportion over 65",
               "Followers")

estimates_zi$label <- factor(
  estimates_zi$label,
  levels = order_of_variables)

estimates_beta$label <- factor(
  estimates_beta$label,
  levels = order_of_variables)

# Order offsets to match paper
order_of_offsets <- c(
  "CDC (offset)",
  "Biden mask (offset)",
  "Trump mask (offset)",
  "Election (offset)"
  )

estimates_zi_offsets$label <- factor(
  estimates_zi_offsets$label,
  levels = order_of_offsets
  )

estimates_beta_offsets$label <- factor(
  estimates_beta_offsets$label,
  levels = order_of_offsets
  )

# Table 1: Combined model (Zero-inflated)
table1 <- estimates_zi[order(estimates_zi$label), ]
table1$variable <- table1$label
table1_to_write <- table1[, 1:8]
write.csv(table1_to_write, "tables/appendix_E_table1.csv", row.names = FALSE)

# Table 2: Combined model (Beta)
table2 <- estimates_beta[order(estimates_beta$label), ]
table2$variable <- table2$label
table2_to_write <- table2[, 1:8]
write.csv(table2_to_write, "tables/appendix_E_table2.csv", row.names = FALSE)

# Table 3: Offsets (Zero-inflated)
table3 <- estimates_zi_offsets[order(estimates_zi_offsets$label), ]
table3$variable <- table3$label
table3_to_write <- table3[, 1:8]
write.csv(table3_to_write, "tables/appendix_E_table3.csv", row.names = FALSE)

# Table 4: Offsets (Beta)
table4 <- estimates_beta_offsets[order(estimates_beta_offsets$label), ]
table4$variable <- table4$label
table4_to_write <- table4[, 1:8]
write.csv(table4_to_write, "tables/appendix_E_table4.csv", row.names = FALSE)