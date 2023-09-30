# Replication file for Figure 1 presented in Boussalis, Coan, Holman (2023)

library(dplyr)
library(ggplot2)
library(lubridate)
library(gridExtra)
library(grid)

# CHANGE to root directory for the replication data. Note that the if
# running the code via RScript, the system() function can be used to
# set the correct directory on Linux and Mac. Windows users may need to
# set the working directory manually.
setwd(system("pwd", intern = TRUE))

# Load data
data <- read.csv('data/data.csv')

# Descriptives ------------------------------------------------------------

# Drop last two weeks of time series
data <- data %>% 
  filter(!(year == 2021 & week > 2))

followers <- data %>% 
  select(c("party", "bioguide", "followers_unscaled")) %>% 
  distinct(.keep_all = FALSE)

## total number of followers
sum(followers$followers_unscaled, na.rm=TRUE)

## total number of followers by party
sum(followers[which(followers$party == "Republican"), ]$followers_unscaled, na.rm=TRUE)
sum(followers[which(followers$party == "Democratic"), ]$followers_unscaled, na.rm=TRUE)
sum(followers[which(followers$party == "Independent"), ]$followers_unscaled, na.rm=TRUE)

## total number of images in dataset
sum(data$n_images_facebook, data$n_images_twitter, na.rm = TRUE)

## total number of bioguides
n_bioguides <- unique(data$bioguide)

## total number of bioguides by party
n_bioguides_r <- unique(data[which(data$party == "Republican"), ]$bioguide)
n_bioguides_d <- unique(data[which(data$party == "Democratic"), ]$bioguide)
n_bioguides_i <- unique(data[which(data$party == "Independent"), ]$bioguide)

## share of moc-weeks with no faces
zero_faces <- data %>%
  filter((n_faces_facebook == 0 | n_faces_twitter == 0))

nrow(zero_faces) / nrow(data)

# Time series plots -------------------------------------------------------

# Weekly share of masks by party

# Fix dates
data$yr_wk_w <- paste(data$year, "-", data$week, "-", "01", sep = "")
data$year_week <- as.Date(data$yr_wk_w, "%Y-%W-%w")

# Calculate total weekly mask share
week_data <- data %>% 
  select(bioguide, party, starts_with("n_"), starts_with("mask_prop_"), national_new_cases,
         national_new_deaths,
         year, week, year_week) %>% 
  filter(party == "Democratic" | party == "Republican") %>% 
  group_by(year_week) %>% 
  summarize(sum_mask_dum = sum(n_mask_dum_facebook + n_mask_dum_twitter, na.rm = TRUE),
            sum_face_dum = sum(n_face_dum_facebook + n_face_dum_twitter, na.rm = TRUE),
            prop2 = sum_mask_dum / sum_face_dum,
            national_new_cases = first(national_new_cases),
            national_new_deaths = first(national_new_deaths))

week_data$national_new_cases[is.na(week_data$national_new_cases)] <- 0
week_data$national_new_deaths[is.na(week_data$national_new_deaths)] <- 0

# Calculate R and D masked images
week_data_party <- data %>% 
  select(bioguide, party, year, week, year_week, starts_with('n_'), national_new_cases, national_new_deaths) %>% 
  filter(party == "Democratic" | party == "Republican") %>% 
  group_by(year_week) %>% 
  summarize(sum_mask_dum_r = sum(n_mask_dum_facebook[party == "Republican"] + n_mask_dum_twitter[party == "Republican"], na.rm = TRUE),
            sum_face_dum_r = sum(n_face_dum_facebook[party == "Republican"] + n_face_dum_twitter[party == "Republican"], na.rm = TRUE),
            sum_mask_dum_d = sum(n_mask_dum_facebook[party == "Democratic"] + n_mask_dum_twitter[party == "Democratic"], na.rm = TRUE),
            sum_face_dum_d = sum(n_face_dum_facebook[party == "Democratic"] + n_face_dum_twitter[party == "Democratic"], na.rm = TRUE),
            prop2_r = sum_mask_dum_r / sum_face_dum_r,
            prop2_d = sum_mask_dum_d / sum_face_dum_d,
            prop2_diff = prop2_d - prop2_r,
            plot_condition = if_else(prop2_diff > 0, "More Democratic", "More Republican"))

combined_data <- left_join(week_data, week_data_party)

# More data
week_data2 <- data %>% 
  select(bioguide, party, year, week, year_week, starts_with('n_')) %>% 
  filter(party == "Democratic" | party == "Republican") %>% 
  group_by(party, year_week) %>% 
  summarize(sum_mask_dum = sum(n_mask_dum_facebook + n_mask_dum_twitter, na.rm = TRUE),
            sum_face_dum = sum(n_face_dum_facebook + n_face_dum_twitter, na.rm = TRUE),
            sum_images = sum(n_images_facebook + n_images_twitter, na.rm = TRUE),
            sum_masks = sum(n_masks_facebook + n_masks_twitter, na.rm = TRUE),
            sum_faces = sum(n_faces_facebook, n_faces_twitter, na.rm = TRUE),
            prop1 = sum_mask_dum / sum_images,
            prop2 = sum_mask_dum / sum_face_dum,
            prop3 = sum_masks / sum_faces)


# Plot time series  -------------------------------------------------------

## Masked images for all parties over all platforms

p1 <- ggplot(data = combined_data, aes(x = year_week)) +
  geom_bar(aes(x = year_week, y = national_new_cases), stat = "identity", alpha = 0.25) +
  geom_line(aes(y = prop2 * (2*max(national_new_cases)))) +
  scale_y_continuous(
    
    # Features of the first axis
    name = "Weekly new cases",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis(trans=~./(1.5*max(combined_data$national_new_cases)), name="Proportion of masked images"))+
  ggtitle("(a) Weekly share of masked images & national COVID-19 cases") +
  theme(panel.border = element_blank(), 
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "grey"),
        axis.title.x = element_text(color = "grey30"),
        axis.title.y = element_text(color = "grey30"),
        legend.position="none",
        plot.title = element_text(hjust = 0.5, size=9),
        text = element_text(size=8))

p1

## Difference in proportion of masked faces between parties
# April 3, 2020 - CDC issues mask recommendation
# May 25, 2020: Biden appears in public wearing a mask.
# July 12, 2020 - Trump wears mask for the first time in public

p2 <- ggplot(data = week_data_party, aes(x = year_week, 
                                         y = prop2_diff,
                                         fill = plot_condition)) +
  geom_bar(stat = "identity") +
  ylab("Dem - Rep share of masked images") +
  xlab("") +
  ggtitle("(b) Difference in share of masked images by MOC's party") +
  geom_hline(yintercept = 0, color = "grey80", size = 0.5) +
  geom_vline(xintercept = as.numeric(as.Date("2020-03-29")), linetype=3, color = "black") +
  geom_vline(xintercept = as.numeric(as.Date("2020-04-26")), linetype=4, color = "blue") +
  geom_vline(xintercept = as.numeric(as.Date("2020-07-12")), linetype=5, color = "red") +
  theme(panel.border = element_blank(), 
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "grey"),
        axis.title.x = element_text(color = "grey30"),
        axis.title.y = element_text(color = "grey30"),
        legend.position="none",
        plot.title = element_text(hjust = 0.5, size=9),
        text = element_text(size=8))
p2_final <- p2 + scale_fill_manual(values=c("blue", "red")) 
p2_final


p3 <- ggplot(data = week_data2, aes(x = year_week, 
                                    y = prop2, 
                                    group = party,
                                    shape = party,
                                    color = party)) +
  geom_point(size = 2) +
  geom_line() +
  geom_hline(yintercept = 0, color = "grey80", size = 0.5) +
  scale_color_manual(values=c('blue','red')) +
  scale_shape_manual(values=c(1, 18)) +
  ylab("") +
  xlab("") +
  ggtitle("(c) Share of masked images by MOC's party") +
  theme(panel.border = element_blank(), 
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "grey"),
        axis.title.x = element_text(color = "grey30"),
        axis.title.y = element_text(color = "grey30"),
        legend.position="none",
        plot.title = element_text(hjust = 0.5, size=9),
        text = element_text(size=8))

p3

# Combine time series plots -----------------------------------------------

lay <- rbind(c(1, 1),
             c(2, 3))
cp <- grid.arrange(p1, p2_final, p3, ncol=2, layout_matrix = lay, heights = c(2,2))

fname <- "figures/fg1.tiff"
ggsave(fname, plot = cp, width = 20, height = 16, units = "cm",  dpi = 300, device = "tiff")
