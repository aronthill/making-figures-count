# =============================================================================
# Making Figures Count
# Plot walkthrough
#
# Work through the same dataset, from the first bar chart to the final figures.
# Run sections 1-3 first, then follow sections 4-16 in order.
#
# Open this file in RStudio and choose:
# Session > Set Working Directory > To Source File Location.
# Run a few lines at a time with Ctrl+Enter (Windows) or Cmd+Enter (Mac).
#
# The data are in ../data/caffeine_attention.csv (80 simulated participants).
# Section 16 saves figures into saved_figures/ inside the code folder.
#
# The numbered section headings let the Quarto guide read the same code.
# Keep these headings when editing; they do not affect running the script.
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Load packages
# -----------------------------------------------------------------------------

# Open this file in RStudio, then choose:
# Session > Set Working Directory > To Source File Location.
# Keep the code and data folders together. Run sections 1-3 first, then work
# down through the plots. Some later plots build on an earlier plot object.
# R 4.1 or later is needed for the |> symbol (the pipe).

# Install only packages that are not already available.
packages <- c("ggplot2", "dplyr", "ragg")
missing_packages <- packages[!vapply(packages, requireNamespace,
                                    logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

library(ggplot2)    # Draw the plots.
library(dplyr)      # Summarise the data for each group.
library(ragg)       # Save clear PNG images.


# -----------------------------------------------------------------------------
# 2. Read the data and calculate the summaries
# -----------------------------------------------------------------------------

# Each row is one participant. These are simulated data only!
# group identifies treatment; vigilance is a score on a 0-100 scale.

if (!file.exists("../data/caffeine_attention.csv")) {
  stop("Cannot find the CSV. Set the working directory to the code folder.")
}
dat <- read.csv("../data/caffeine_attention.csv")

# Put placebo first so the group order stays the same throughout.
dat <- dat |>
  mutate(group = factor(group, levels = c("Placebo", "Caffeine 200 mg")),
         xnum = as.numeric(group))


# Create a summary table from the data - this is needed for the bar plots
# -----------------------------------------------------------------------

# summ is a new table with one row per group.
# n: number of participants; mean: average score; sd: standard deviation.
# se: standard error of the mean (SD / square root of n).
# ci: half-width of a 95% t confidence interval, so its ends are mean +/- ci.
summ <- dat |>
  group_by(group) |>
  summarise(n = n(),
            mean = mean(vigilance),
            sd = sd(vigilance),
            se = sd / sqrt(n),
            ci = qt(0.975, n - 1) * se,
            .groups = "drop")

print(summ)


# -----------------------------------------------------------------------------
# 3. Set colours, labels and text sizes
# -----------------------------------------------------------------------------

# These settings are reused throughout. Edit the colours here rather than
# changing them separately in every figure. Group sizes come from summ.
pal <- c("Placebo" = "#4B77A8", "Caffeine 200 mg" = "#D98C1F")
group_labels <- setNames(paste0(summ$group, "\n(n = ", summ$n, ")"), summ$group)


# A list lets us add the same colours, labels and theme with + style.
# Change base_size to adjust the text, or remove selected gridlines below.
style <- list(
  scale_fill_manual(values = pal, guide = "none"),
  scale_colour_manual(values = pal, guide = "none"),
  scale_x_discrete(labels = group_labels),
  labs(x = NULL, y = "Vigilance score (0-100)"),
  theme_minimal(base_size = 14, base_family = "sans"),
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.margin = margin(10, 12, 10, 10))
)

# This theme is used for the compact violin and refined raincloud.
# Text is sized for a 160 x 125 mm figure. Check it at the final printed size.
theme_paper <- theme_minimal(base_size = 15, base_family = "sans") +
  theme(axis.title.y = element_text(size = 15, margin = margin(r = 10)),
        axis.text = element_text(size = 13, colour = "grey15"),
        axis.title.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "grey91", linewidth = 0.3),
        plot.margin = margin(10, 12, 8, 8))


# Now with housekeeping out of the way, we can start to create the plots!

# -----------------------------------------------------------------------------
# 4. The first bar chart
# -----------------------------------------------------------------------------

# Simple initial bar plot
p_first <- ggplot(summ,
  aes(group, mean)) +
  geom_col(fill = "grey60", width = 0.6) +
  geom_errorbar(aes(
    ymin = mean - se,
    ymax = mean + se), width = 0.15) +
  labs(x = "group", y = "vigilance") +
  scale_y_continuous(limits = c(0, 100)) +
  theme_grey(base_size = 7)

print(p_first)


# Optional - save out figure
# --------------------------

# Currently, I have not added saving options for these initial plots. However, 
# if you want to save out the figure you can uncomment this section below
# (to uncomment, highlight the text and press Command + Shif +C [Mac]). 

# # Create the output folder if it does not already exist.
# fig_dir <- "saved_figures"
# dir.create(fig_dir, showWarnings = FALSE)
# 
# # Save the first bar chart as a PNG.
# ggsave(
#   filename = file.path(fig_dir, "first_bar_chart.png"),
#   plot = p_first,
#   width = 160,
#   height = 125,
#   units = "mm",
#   dpi = 320,
#   device = ragg::agg_png,
#   bg = "white"
# )


# -----------------------------------------------------------------------------
# 5. Create again with clearer labels and confidence intervals
# -----------------------------------------------------------------------------

# Use colour and readable labels, and show the group sample sizes.
# Changing SE to 95% CIs changes the information as well as the appearance.
# geom_col uses the means already calculated in summ.
p_bar <- ggplot(summ,
  aes(group, mean, fill = group)) +
  geom_col(width = 0.55) +
  geom_errorbar(aes(
    ymin = mean - ci,
    ymax = mean + ci), width = 0.12) +
  style +
  labs(subtitle = "Means and 95% CIs") +
  scale_y_continuous(
    limits = c(0, 100),
    expand = expansion(mult = c(0, 0.05)))

print(p_bar)


# -----------------------------------------------------------------------------
# 7. Boxplots
# -----------------------------------------------------------------------------

# Use the individual scores in the dat variable. The box shows the median and middle 50%.
# Whiskers reach observations within 1.5 x IQR of the box hinges.
# Try changing width or alpha (0 = transparent, 1 = opaque).
p_box <- ggplot(dat,
  aes(group, vigilance, fill = group)) +
  geom_boxplot(width = 0.35,
    alpha = 0.5) +
  style

print(p_box)

# -----------------------------------------------------------------------------
# 8. Histograms
# -----------------------------------------------------------------------------

# Create a simple histogram for each group 
p_hist <- ggplot(dat,
  aes(vigilance, fill = group)) +
  geom_histogram(binwidth = 4,
    boundary = 0, colour = "white") +
  facet_wrap(~ group, ncol = 1) +
  scale_fill_manual(values = pal,
    guide = "none") +
  labs(x = "Vigilance score (0-100)",
    y = "Number of participants") +
  theme_minimal(base_size = 14)

print(p_hist)


# -----------------------------------------------------------------------------
# 9. Density plots
# -----------------------------------------------------------------------------

# Similar to historgram, but with added smoothing. 
p_density <- ggplot(dat,
  aes(vigilance, fill = group,
    colour = group)) +
  geom_density(adjust = 1, alpha = 0.3,
    linewidth = 0.8) +
  # Rug marks make the observed scores visible below the smooth estimate.
  geom_rug(alpha = 0.4, sides = "b") +
  # Separate panels make it easier to compare shapes using common axes.
  facet_wrap(~ group, ncol = 1) +
  # Leave room for the density tails; this range includes all supplied scores.
  scale_x_continuous(limits = c(20, 100)) +
  scale_fill_manual(values = pal,
    guide = "none") +
  scale_colour_manual(values = pal,
    guide = "none") +
  labs(x = "Vigilance score (0-100)",
    y = "Density") +
  theme_minimal(base_size = 14)

print(p_density)


# -----------------------------------------------------------------------------
# 10. Violin plots with a boxplot
# -----------------------------------------------------------------------------

# Violin plots can be useful for showing data variability. Here, we'll plot 
# a violin plot with a box-plot inside. 

p_violin <- ggplot(dat,
  aes(group, vigilance, fill = group)) +
  geom_violin(trim = TRUE,
    adjust = 0.8, alpha = 0.4) +
  geom_boxplot(width = 0.14,
    fill = "white") +
  style

print(p_violin)

# -----------------------------------------------------------------------------
# 11. A simpler violin plot
# -----------------------------------------------------------------------------

# An alternative style violin plot. Here, the dot is the median, the thick dark
# line is the 50% of scores (from 25th - 75th percentile), the thin line is the
# lowest to highest scores. 

violin_summary <- dat |>
  group_by(group) |>
  summarise(low = min(vigilance), high = max(vigilance),
            q1 = quantile(vigilance, 0.25),
            q3 = quantile(vigilance, 0.75),
            centre = median(vigilance), .groups = "drop")
violin_style <- list(
  scale_fill_manual(values = pal, guide = "none"),
  scale_x_discrete(labels = group_labels, expand = expansion(add = 0.6)),
  scale_y_continuous(breaks = seq(40, 80, 10)),
  labs(y = "Vigilance score (0-100)"),
  theme_paper
)


# Start with the full violin and overlay the range, IQR and median, in that
# order. colour = NA removes the violin outline. To show individual scores as
# well, use the raincloud or points-and-boxplot example.
p_compact <- ggplot(dat,
  aes(group, vigilance)) +
  geom_violin(aes(fill = group),
    width = 0.72, adjust = 0.8,
    alpha = 0.7, colour = NA) +
  # Thin line: the lowest to highest observed score.
  geom_linerange(data = violin_summary,
    aes(y = centre, ymin = low, ymax = high),
    linewidth = 0.55, colour = "grey20") +
  # Thick line: the middle 50% of scores.
  geom_linerange(data = violin_summary,
    aes(y = centre, ymin = q1, ymax = q3),
    linewidth = 2.8, colour = "grey20") +
  # White dot: the median. It is drawn last so the lines do not cover it.
  geom_point(data = violin_summary,
    aes(y = centre), shape = 21, size = 3.5,
    fill = "white", colour = "grey20") +
  violin_style

print(p_compact)


# -----------------------------------------------------------------------------
# 12. Individual scores
# -----------------------------------------------------------------------------

# Very simple jitter plot of individual scores. On its own this is not particularly
# informative, but it can be combined with other plots (e.g., box plot). 

p_jitter <- ggplot(dat,
  aes(group, vigilance, colour = group)) +
  geom_point(size = 2.2, alpha = 0.7,
    position = position_jitter(
      width = 0.10, height = 0,
      seed = 1)) +
  style

print(p_jitter)


# -----------------------------------------------------------------------------
# 13. Points with a boxplot
# -----------------------------------------------------------------------------

# Box plot with jittered individual values overlaid. 
p_boxpoints <- ggplot(dat,
  aes(group, vigilance)) +
  geom_boxplot(aes(fill = group),
    width = 0.35, alpha = 0.3,
    outlier.shape = NA) +
  geom_point(aes(colour = group),
    size = 2.2, alpha = 0.7,
    position = position_jitter(
      width = 0.10, height = 0, seed = 1)) +
  style

print(p_boxpoints)


# -----------------------------------------------------------------------------
# 14. Raincloud plots
# -----------------------------------------------------------------------------

# Raincloud plots can be very useful as they convey a lot of data. They combine
# several plotting elements including individual data, a boxplot, and a violin
# plot all in one figure!

cloud <- dat |>
  group_by(group) |>
  group_modify(~ {
    d <- density(.x$vigilance, adjust = 0.8,
                 from = min(.x$vigilance), to = max(.x$vigilance))
    data.frame(score = c(d$x[1], d$x, tail(d$x, 1)),
               width = c(0, d$y / max(d$y), 0))
  }) |>
  ungroup() |>
  mutate(xnum = as.numeric(group))

# Numeric x positions (1 and 2) let us offset the layers horizontally.
# The offsets only control spacing; they have no scientific meaning.
rain_style <- list(
  scale_fill_manual(values = pal, guide = "none"),
  scale_colour_manual(values = pal, guide = "none"),
  scale_x_continuous(breaks = 1:2, labels = unname(group_labels),
                     limits = c(0.65, 2.45)),
  labs(x = NULL, y = "Vigilance score (0-100)"),
  theme_minimal(base_size = 14, base_family = "sans"),
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.margin = margin(10, 12, 10, 10))
)

p_rain <- ggplot() +
  geom_polygon(data = cloud, aes(
    xnum + 0.05 + width * 0.26, score,
    fill = group), alpha = 0.45) +
  geom_boxplot(data = dat, aes(
    xnum - 0.05, vigilance, group = group),
    width = 0.07, fill = "white",
    outlier.shape = NA) +
  geom_point(data = dat, aes(
    xnum - 0.18, vigilance, colour = group),
    size = 2.2, alpha = 0.7,
    position = position_jitter(
      width = 0.04, height = 0, seed = 1)) +
  rain_style

print(p_rain)

# -----------------------------------------------------------------------------
# 15. Refine the raincloud
# -----------------------------------------------------------------------------

# We can do some tweaks here to refine the raincloud plot and perhaps make it
# a little nicers aesthetically (really just personal preference!)

# Try playing around with some of the options (e.g., line width, size for the
# geom_point dots etc) and re-draw to see changes. 

rain_canvas <- ggplot() +
  geom_polygon(data = cloud,
    aes(xnum + 0.05 + width * 0.28, score, fill = group), alpha = 0.42) +
  scale_fill_manual(values = pal, guide = "none") +
  scale_x_continuous(breaks = 1:2, labels = unname(group_labels),
                     limits = c(0.61, 2.40)) +
  scale_y_continuous(breaks = seq(40, 80, 10)) +
  labs(y = "Vigilance score (0-100)")

p_polished <- rain_canvas +
  geom_boxplot(data = dat, aes(
    xnum - 0.055, vigilance, group = group),
    width = 0.09, fill = "white",
    colour = "grey25", linewidth = 1.5,
    outlier.shape = NA) +
  geom_point(data = dat, aes(
    xnum - 0.22, vigilance, fill = group),
    shape = 21, size = 5, stroke = 0.35,
    colour = "white", alpha = 0.95,
    position = position_jitter(
      width = 0.065, height = 0, seed = 1)) +
  theme_paper

print(p_polished)

# -----------------------------------------------------------------------------
# 16. Save figures for a manuscript
# -----------------------------------------------------------------------------

# Run the earlier sections first to create p_polished and p_compact.


# A. Create a folder for the saved figures
# -----------------------------------------------------------------------------

# This creates saved_figures inside your current working directory.
# If the folder already exists, its contents are kept.
fig_dir <- "saved_figures"

dir.create(fig_dir, showWarnings = FALSE)



# B. Save the refined raincloud plot
# -----------------------------------------------------------------------------

# PNG is useful for slides. PDF keeps text and lines sharp when resized.

ggsave(
  filename = file.path(fig_dir, "raincloud_refined.png"),
  plot = p_polished,
  width = 160,
  height = 125,
  units = "mm",
  dpi = 320,
  device = ragg::agg_png,
  bg = "white"
)

# PDF is a vector format, so we don't need a DPI setting here.
ggsave(
  filename = file.path(fig_dir, "raincloud_refined.pdf"),
  plot = p_polished,
  width = 160,
  height = 125,
  units = "mm",
  bg = "white"
)


# C. Prepare and save a narrower violin plot
# -----------------------------------------------------------------------------

# Make a separate version for a 90 mm-wide figure.
# Adjust text sizes and margins for this smaller layout.
# The original p_compact plot stays unchanged.

p_compact_small <- p_compact +
  theme(
    axis.title.y = element_text(size = 11, margin = margin(r = 5)),
    axis.text = element_text(size = 10),
    plot.margin = margin(6, 5, 6, 5)
  )

# Display it before saving.
print(p_compact_small)

ggsave(
  filename = file.path(fig_dir, "violin_compact_90mm.png"),
  plot = p_compact_small,
  width = 90,
  height = 100,
  units = "mm",
  dpi = 320,
  device = ragg::agg_png,
  bg = "white"
)

ggsave(
  filename = file.path(fig_dir, "violin_compact_90mm.pdf"),
  plot = p_compact_small,
  width = 90,
  height = 100,
  units = "mm",
  bg = "white"
)


