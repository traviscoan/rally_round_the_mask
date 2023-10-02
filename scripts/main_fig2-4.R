# Replication file for Figures 2-4 presented in Boussalis, Coan, Holman (2023)

library(ggplot2)
library(dplyr)
library(cowplot)
library(stringr)
library(gridExtra)

# CHANGE to root directory for the replication data. Note that the if
# running the code via RScript, the system() function can be used to
# set the correct directory on Linux and Mac. Windows users may need to
# set the working directory manually.
setwd(system("pwd", intern = TRUE))

inverse_logodds <- function(log_odds) {
  log((1 - plogis(log_odds)) / plogis(log_odds))
}

plot_mask_results <- function(file_path1, file_path2 = NULL, plot_title) {
  
  # Function to get plot data from a single file
  get_plot_data <- function(file_path) {
    if (is.null(file_path)) {
      return(list(pl_data = NULL, var_list = NULL))
    }
    
    file_number <- as.numeric(str_extract(file_path, "(?<=_table)\\d+"))
    
    if (is.na(file_number) || file_number == "") {
      file_number <- NA_character_
    }
    
    if (is.na(file_number) || file_number == "") {
      stop("Failed to extract file number from file path: ", file_path)
    }
    
    file_number <- as.numeric(file_number)
    
    var_list <- if (file_number %in% c(1, 2)) {
      c("Republican", "Ideology (DW Nominate 1)", 
        "Ideology (DW Nominate 2)", "Net Trump vote", "Senator", "Gender", 
        "Age", "Cases", "Deaths", "State mask mandate", "Clinton vote share", 
        "Margin of victory", "Median income", "Population density ", 
        "Proportion over 65", "Followers")
    } else if (file_number %in% c(5, 6, 9, 10)) {
      c("Ideology (DW Nominate 1)", 
        "Ideology (DW Nominate 2)", "Net Trump vote", "Senator", "Gender", 
        "Age", "Cases", "Deaths", "State mask mandate", "Clinton vote share", 
        "Margin of victory", "Median income", "Population density ", 
        "Proportion over 65", "Followers")
    } else {
      c("Intercept", "CDC Rec.", "Biden mask", "Trump mask", "Election") 
    }
    
    model_type <- ifelse(file_number %in% c(1, 2, 5, 6, 9, 10), "covariate", "event")
    
    pl_data <- read.csv(file_path) %>% 
      mutate(
        variable = recode(variable, 
                          "CDC (offset)" = "CDC Rec.", 
                          "Biden mask (offset)" = "Biden mask", 
                          "Trump mask (offset)" = "Trump mask", 
                          "Election (offset)" = "Election"), 
        model_type = model_type,
        party = case_when(
          file_number %in% 1:4 ~ "All",
          file_number %in% 5:8 ~ "Democrats",
          file_number %in% 9:12 ~ "Republicans",
          TRUE ~ NA_character_
        ),
        transform = (model_type == "covariate" & file_number %% 2 == 1) | (model_type == "event" & file_number %% 2 == 1)
      ) %>%
      filter(!variable %in% c(NA, "Intercept", "Independent", "Senator", "Gender", "Age", "Clinton vote share", "Median income", "Population density ", "Proportion over 65")) %>%
      rowwise() %>%
      mutate(
        across(c(mean, median, X2.5., X5., X95., X97.5.), 
               ~ ifelse(transform, inverse_logodds(.), .), .names = "new_{col}")
      )
    return(list(pl_data = pl_data, var_list = var_list))
  }
  
  # Get plot data for both files
  data1 <- get_plot_data(file_path1)
  data2 <- get_plot_data(file_path2)
  
  # Combine the data from both files
  if (is.null(data2$pl_data)) {
    pl_data <- data1$pl_data
    var_list <- data1$var_list
  } else {
    pl_data <- bind_rows(data1$pl_data, data2$pl_data)
    var_list <- unique(c(data1$var_list, data2$var_list))
  }
  
  cols <- c("Republicans" = "#b80000", "Democrats" = "#1f96ff", "All" = "#696969") 
  shapes <- c("Republicans" = 15, "Democrats" = 17, "All" = 19) 
  
  p <- ggplot(pl_data, aes(y = factor(variable, levels = rev(var_list)),
                           x = new_mean,
                           color = party,
                           shape = party)) +
    geom_vline(aes(xintercept = 0), color = "black", alpha = 0.5) +
    geom_point(position = position_dodge(width = 0.6),
               size = 2) +
    geom_errorbarh(aes(xmin = new_X2.5.,
                       xmax = new_X97.5.),
                   size = 0.5, 
                   height = 0,
                   position = position_dodge(width = 0.6)) +
    geom_errorbarh(aes(xmin = new_X5.,
                       xmax = new_X95.),
                   size = 1, 
                   height = 0,
                   position = position_dodge(width = 0.6)) +
    labs(x = "Log odds", y = NULL) +
    ggtitle(plot_title) + 
    scale_color_manual(values= cols) +
    scale_fill_manual(values= cols) +
    scale_shape_manual(values = shapes) +
    theme(panel.border = element_rect(colour = "grey", fill=NA, size=1),
          panel.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          axis.line = element_line(colour = "grey"),
          axis.title.x = element_text(color = "grey30"),
          axis.title.y = element_text(color = "grey30"),
          axis.text.y = element_text(color = "grey30", size = 10),
          legend.position="none",
          plot.title = element_text(size=11),
          text = element_text(size=10))
  
  return(p)
}

# Get a list of all CSV files of main results (Appendix E)
csv_files <- list.files("tables", pattern = ".*_E_.*.csv", full.names = TRUE)
csv_files <- csv_files[order(as.numeric(gsub(".*table(\\d+)\\.csv", "\\1", csv_files)))]

# Define the plot titles
plot_titles <- c(
  "(a) MOC posts mask (Zero-inflated)",
  "(b) Share of face images w/mask (Beta)",
  "(a) MOC posts mask (Zero-inflated)",
  "(b) Share of face images w/mask (Beta)",
  "(a) MOC posts mask (Zero-inflated)",
  "(b) Share of face images w/mask (Beta)",
  "(a) MOC posts mask (Zero-inflated)",
  "(b) Share of face images w/mask (Beta)"
)

plot_list <- list()

for (i in seq(1, length(csv_files) - 4)) {
  if (i %in% c(3, 4)) next
  
  plot_title <- plot_titles[i]
  
  if (i <= 2) {
    plot <- plot_mask_results(csv_files[i], NULL, plot_title)
  } else {
    plot <- plot_mask_results(csv_files[i], csv_files[i + 4], plot_title)
  }
  
  plot_list[[length(plot_list) + 1]] <- plot
}

# Combine plots and write to disk
figure_2 <- grid.arrange(grobs = c(plot_list[1], plot_list[2]), ncol=2)
fname <- paste0("figures/fg2.tiff")
ggsave(fname, plot = figure_2, width = 25, height = 10, units = "cm",  dpi = 300, device = "tiff")

figure_3 <- grid.arrange(grobs = c(plot_list[3], plot_list[4]), ncol=2)
fname <- paste0("figures/fg3.tiff")
ggsave(fname, plot = figure_3, width = 25, height = 10, units = "cm",  dpi = 300, device = "tiff")

figure_4 <- grid.arrange(grobs = c(plot_list[5], plot_list[6]), ncol=2)
fname <- paste0("figures/fg4.tiff")
ggsave(fname, plot = figure_4, width = 25, height = 10, units = "cm",  dpi = 300, device = "tiff")
