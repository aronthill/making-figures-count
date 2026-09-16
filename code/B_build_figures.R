# Making Figures Count: synthetic caffeine and attention example
# Generated from B_Figure_Pipeline.qmd by C_sync_scripts.R.
# To maintain this teaching pack, edit the .qmd and regenerate.
# Run from code/ with ../data/caffeine_attention.csv in place.
# Required packages: ggplot2, dplyr, readr, patchwork, ragg, systemfonts.

# ---- setup ----
# Packages used throughout the guide.
library(ggplot2)
library(dplyr)
library(readr)
library(patchwork)


# Use an installed font so the code also runs on another computer.
pick_font <- function(candidates = c("Lato", "Source Sans Pro", "Helvetica Neue",
                                     "Helvetica", "Arial", "sans")) {
  installed <- systemfonts::system_fonts()$family
  candidates[candidates %in% c(installed, "sans")][1]
}
ft <- pick_font()

# Read one row per participant and keep the treatment groups in this order.
dat <- read_csv("../data/caffeine_attention.csv", show_col_types = FALSE) |>
  mutate(group = factor(group, levels = c("Placebo", "Caffeine 200 mg")),
         xnum  = as.numeric(group))

# se is the standard error; ci is the half-width of a 95% t interval.
summ <- dat |>
  group_by(group) |>
  summarise(n = n(), mean = mean(vigilance), sd = sd(vigilance),
            se = sd / sqrt(n), ci = qt(0.975, n - 1) * se, .groups = "drop") |>
  mutate(xnum = as.numeric(group))

# These summaries are used in the optional results table.
descr <- dat |>
  group_by(group) |>
  summarise(n = n(), median = median(vigilance),
            q1 = quantile(vigilance, 0.25), q3 = quantile(vigilance, 0.75),
            .groups = "drop")

tt <- t.test(vigilance ~ group, data = dat)

# Reuse the same group colours in every figure.
ok <- c(Placebo = "#4B77A8", `Caffeine 200 mg` = "#D98C1F")
ink <- "grey20"; ink2 <- "grey38"; rule <- "grey88"

# Shared formatting. Change it here to apply it across the figure sequence.
make_theme_talk <- function(base_size = 11) {
  theme_minimal(base_size = base_size, base_family = ft) +
    theme(
      plot.title          = element_text(size = base_size + 1.5, face = "bold",
                                         colour = ink, margin = margin(b = 3)),
      plot.subtitle       = element_text(size = base_size - 1.2, colour = ink2,
                                         margin = margin(b = 14)),
      plot.caption        = element_text(size = base_size - 2.7, colour = ink2,
                                         hjust = 0, margin = margin(t = 12),
                                         lineheight = 1.25),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title          = element_text(size = base_size - 1.2, colour = ink2),
      axis.title.y        = element_text(margin = margin(r = 9)),
      axis.title.x        = element_text(margin = margin(t = 9)),
      axis.text           = element_text(size = base_size - 1.7, colour = ink2),
      axis.ticks          = element_blank(),
      panel.grid.minor    = element_blank(),
      panel.grid.major.x  = element_blank(),
      panel.grid.major.y  = element_line(colour = rule, linewidth = 0.3),
      legend.text         = element_text(size = base_size - 1.7, colour = ink2),
      legend.key.height   = unit(11, "pt"),
      plot.margin         = margin(13, 15, 11, 13)
    )
}
theme_talk    <- make_theme_talk(11)   # figures 1-5
theme_talk_lg <- make_theme_talk(13)   # figures 6 and 6b
theme_talk_xl <- make_theme_talk(14) + # figures 7 and 8 - publication-ready
  theme(panel.border = element_rect(colour = "grey55", fill = NA, linewidth = 0.6))

# Save a PNG in figures/ using the same graphics device as the guide.
save_fig <- function(name, plot, w, h) {
  dir.create("../figures", showWarnings = FALSE)
  ggsave(file.path("../figures", name), plot, width = w, height = h,
         dpi = 320, bg = "white", device = ragg::agg_png)
  invisible(plot)
}

YL <- "Vigilance score (0-100)"

# This score range is specific to the example dataset.
score_axis <- function() scale_y_continuous(limits = c(35, 85), breaks = seq(40, 80, 10))

# ---- fig-badbar ----

# The table summ contains the group means and standard errors.
p1 <- ggplot(summ, aes(x = group, y = mean)) +
  # Draw one bar at each supplied mean.
  geom_col(fill = "grey60", width = 0.6) +
  # Error bars extend one standard error either side of the mean.
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.15) +
  labs(x = "group", y = "vigilance") +
  theme_grey(base_size = 11, base_family = ft)

# Small labels and a full 0–100 axis recreate the first draft.
p1_bad <- p1 +
  scale_y_continuous(limits = c(0, 100)) +
  theme_grey(base_size = 7, base_family = ft)

save_fig("01_bad_bar.png", p1_bad, 4.6, 3.8)

# ---- fig-truncated ----
lab <- theme(plot.title = element_text(size = 10.5, family = ft, colour = ink))

# Reuse the same plot; only the visible axis range changes.
p2 <- (p1 + labs(title = "y axis starts at 0") + lab) +
  (p1 + coord_cartesian(ylim = c(55, 65)) +
       labs(title = "y axis starts at 55") + lab)

save_fig("02_truncated_axis.png", p2, 8.4, 3.8)

# ---- fig-honestbar ----
# Map fill to group so the two bars have consistent colours.
p3 <- ggplot(summ, aes(x = group, y = mean, fill = group)) +
  geom_col(width = 0.5) +
  # Use the 95% CI half-width instead of the standard error.
  geom_errorbar(aes(ymin = mean - ci, ymax = mean + ci), width = 0.1,
                linewidth = 0.5, colour = ink) +
  # The x-axis already names the groups, so no legend is needed.
  scale_fill_manual(values = ok, guide = "none") +
  scale_y_continuous(limits = c(0, 90), breaks = seq(0, 90, 15),
                     expand = expansion(mult = c(0, 0.02))) +
  labs(x = NULL, y = YL,
       title = "Group means and uncertainty",
       subtitle = "Group means with 95% confidence intervals, n = 40 per group") +
  theme_talk

save_fig("03_honest_bar.png", p3, 5.2, 4.3)

# ---- fig-boxplot ----
# Use participant-level data, rather than the summary table.
p4 <- ggplot(dat, aes(x = group, y = vigilance, fill = group)) +
  geom_boxplot(width = 0.32, alpha = 0.5, linewidth = 0.4, colour = ink,
               outlier.shape = 21, outlier.size = 1.6, outlier.alpha = 0.7) +
  scale_fill_manual(values = ok, guide = "none") +
  score_axis() +
  labs(x = NULL, y = YL,
       title = "A box plot",
       subtitle = "Five numbers instead of one: median, quartiles, whiskers") +
  theme_talk

save_fig("04_boxplot.png", p4, 5.2, 4.3)

# ---- fig-histogram ----
binwidth5 <- 4

dens5 <- dat |>
  group_by(group) |>
  group_modify(~ {
    d <- density(.x$vigilance, adjust = 0.9)
    tibble(x = d$x, y = d$y * nrow(.x) * binwidth5)
  }) |>
  ungroup()

p5 <- ggplot(dat, aes(x = vigilance)) +
  geom_histogram(aes(fill = group), binwidth = binwidth5, boundary = 0, colour = "white",
                 linewidth = 0.4, alpha = 0.55) +
  geom_line(data = dens5, aes(x = x, y = y, colour = group), linewidth = 0.9) +
  geom_vline(data = summ, aes(xintercept = mean), linetype = "22",
             colour = ink, linewidth = 0.4) +
  facet_wrap(~ group, ncol = 1, scales = "fixed") +
  scale_fill_manual(values = ok, guide = "none") +
  scale_colour_manual(values = ok, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = YL, y = "Participants",
       title = "A histogram",
       subtitle = "Bin width 4 points, curve: kernel density (rescaled).\nDashed line marks the group mean.") +
  theme_talk +
  theme(panel.grid.major.x = element_line(colour = rule, linewidth = 0.3),
        strip.text = element_text(face = "bold", hjust = 0, size = 9.8,
                                  colour = ink, margin = margin(b = 4)),
        panel.spacing.y = unit(14, "pt"))

save_fig("05_histogram.png", p5, 5.4, 4.8)

# ---- fig-violin ----
# adjust controls smoothing; smaller values show more detail.
p6 <- ggplot(dat, aes(x = group, y = vigilance, fill = group)) +
  geom_violin(width = 0.62, alpha = 0.55, colour = ink, linewidth = 0.35,
              trim = TRUE, adjust = 0.8) +
  stat_summary(fun = median, geom = "point", size = 2.6, colour = "white") +
  stat_summary(fun = median, geom = "point", size = 1.5, colour = ink) +
  scale_fill_manual(values = ok, guide = "none") +
  score_axis() +
  labs(x = NULL, y = YL,
       title = "A violin plot",
       subtitle = "Width shows estimated density. Point marks the median.") +
  theme_talk_lg

save_fig("06_violin.png", p6, 5.6, 4.5)

# ---- fig-violinbox ----
# Draw the violin first so the narrow box remains visible on top.
p6b <- ggplot(dat, aes(x = group, y = vigilance, fill = group)) +
  geom_violin(width = 0.62, alpha = 0.4, colour = ink, linewidth = 0.3,
              trim = TRUE, adjust = 0.8) +
  geom_boxplot(width = 0.14, fill = "white", colour = ink, linewidth = 0.4,
               outlier.shape = NA) +
  scale_fill_manual(values = ok, guide = "none") +
  score_axis() +
  labs(x = NULL, y = YL,
       title = "Violin + box",
       subtitle = "Distribution shape, median and interquartile range.") +
  theme_talk_lg

save_fig("06b_violin_box.png", p6b, 5.6, 4.5)

# ---- fig-points ----
# Share axes and labels across the three panels.
point_base <- ggplot(dat, aes(x = group, y = vigilance)) +
  scale_colour_manual(values = ok, guide = "none") +
  scale_x_discrete(labels = c("Placebo\n(n = 40)", "Caffeine 200 mg\n(n = 40)")) +
  coord_cartesian(ylim = c(35, 85)) +
  labs(x = NULL, y = YL) + theme_talk
p_points0 <- point_base + geom_point(aes(colour = group), alpha = 0.7, size = 2)
# Horizontal jitter separates overlaps without changing any scores.
p_points <- point_base +
  geom_point(aes(colour = group), alpha = 0.7, size = 2,
             position = position_jitter(width = 0.10, height = 0, seed = 1))
# Draw the box first, then the points. Hide duplicate outlier symbols.
p_points_box <- point_base +
  geom_boxplot(width = 0.22, fill = "white", colour = ink,
               outlier.shape = NA, linewidth = 0.4) +
  geom_point(aes(colour = group), alpha = 0.7, size = 2,
             position = position_jitter(width = 0.10, height = 0, seed = 1))
p_points_sequence <- (p_points0 + labs(title = "1. Overlapping points")) +
  (p_points + labs(title = "2. Horizontal jitter")) +
  (p_points_box + labs(title = "3. Points + box"))
save_fig("06c_points_sequence.png", p_points_sequence, 10.5, 3.8)
save_fig("06c_points.png", p_points, 5.2, 4.3)
save_fig("06d_points_box.png", p_points_box, 5.2, 4.3)

# ---- fig-raincloud ----
# Estimate each cloud and scale it to its own maximum width.
cloud <- dat |>
  group_by(group) |>
  group_modify(~ {
    d <- density(.x$vigilance, adjust = 0.8,
                 from = min(.x$vigilance), to = max(.x$vigilance))
    tibble(v = c(d$x[1], d$x, d$x[length(d$x)]),
           w = c(0, d$y / max(d$y), 0))
  }) |>
  ungroup() |>
  mutate(xnum = as.numeric(group))

# Horizontal offsets place the cloud, box and points beside one another.
rain_layers <- function(point_aes) list(
  geom_polygon(data = cloud, aes(x = xnum + 0.05 + w * 0.26, y = v, fill = group),
               colour = NA, alpha = 0.5),
  geom_boxplot(data = dat, aes(x = xnum - 0.055, y = vigilance, group = group),
               width = 0.06, fill = "white", alpha = 0.9, outlier.shape = NA,
               linewidth = 0.4, colour = ink),
  # height = 0 preserves scores; seed = 1 makes the jitter repeatable.
  geom_point(data = dat, point_aes, size = 2.3, alpha = 0.78, stroke = 0,
             position = position_jitter(width = 0.042, height = 0, seed = 1)),
  scale_x_continuous(breaks = 1:2, labels = paste0(levels(dat$group), "\n(n = 40)"),
                     limits = c(0.72, 2.36))
)

# Assemble the layers, labels and shared formatting.
p7 <- ggplot() +
  rain_layers(aes(x = xnum - 0.19, y = vigilance, colour = group)) +
  scale_colour_manual(values = ok, guide = "none") +
  scale_fill_manual(values = ok, guide = "none") +
  labs(x = NULL, y = YL,
       title = "A raincloud plot",
       subtitle = "Rain: every participant. Cloud: kernel density. Box: median and IQR.") +
  score_axis() +
  theme_talk_xl

save_fig("07_raincloud.png", p7, 6.2, 4.8)

# ---- fig-reveal ----
dat2 <- dat |> mutate(sub = ifelse(is.na(metaboliser), "Placebo",
                                   paste(metaboliser, "metaboliser")),
                      sub = factor(sub, levels = c("Placebo", "Fast metaboliser",
                                                   "Slow metaboliser")))
pal2 <- c("Placebo" = "#4B77A8", "Fast metaboliser" = "#2E8B6F", "Slow metaboliser" = "#B5628F")

p8 <- ggplot() +
  geom_polygon(data = cloud, aes(x = xnum + 0.05 + w * 0.26, y = v, group = group),
               fill = "grey72", colour = NA, alpha = 0.4) +
  geom_boxplot(data = dat, aes(x = xnum - 0.055, y = vigilance, group = group),
               width = 0.06, fill = "white", alpha = 0.9, outlier.shape = NA,
               linewidth = 0.4, colour = ink) +
  geom_point(data = dat2, aes(x = xnum - 0.19, y = vigilance, colour = sub),
             size = 2.3, alpha = 0.8, stroke = 0,
             position = position_jitter(width = 0.042, height = 0, seed = 1)) +
  scale_colour_manual(values = pal2, name = NULL) +
  scale_x_continuous(breaks = 1:2, labels = paste0(levels(dat$group), "\n(n = 40)"), limits = c(0.72, 2.36)) +
  labs(x = NULL, y = YL,
       title = "The reveal",
       subtitle = "Invented subgroup labels used to generate these synthetic data") +
  score_axis() +
  theme_talk_xl +
  theme(legend.position = "top", legend.justification = "left",
        legend.key.height = unit(13, "pt"),
        legend.background = element_rect(fill = "white", colour = "grey70",
                                         linewidth = 0.35),
        legend.margin = margin(t = 6, b = 6, l = 9, r = 9),
        legend.box.margin = margin(b = 4))

save_fig("08_reveal.png", p8, 6.2, 5.0)

# ---- fig-manuscript ----
# Keep the data layers and set text sizes for the manuscript export.
p_paper <- p7 + labs(title = NULL, subtitle = NULL) +
  theme_minimal(base_size = 10, base_family = ft) +
  theme(axis.title = element_text(size = 10, colour = ink),
        axis.text = element_text(size = 9, colour = ink),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(colour = "grey90", linewidth = 0.25),
        plot.margin = margin(6, 6, 6, 6))
# plot = names the exact object to save; width and height are in millimetres.
ggsave("../figures/09_manuscript.png", plot = p_paper,
       width = 160, height = 125, units = "mm", dpi = 320,
       bg = "white", device = ragg::agg_png)
ggsave("../figures/09_manuscript.pdf", plot = p_paper,
       width = 160, height = 125, units = "mm", bg = "white",
       device = grDevices::cairo_pdf)
# Check whether group labels still make the figure clear without colour.
p_paper_grey <- p_paper +
  scale_colour_manual(values = c(Placebo = "grey30", `Caffeine 200 mg` = "grey55"),
                      guide = "none") +
  scale_fill_manual(values = c(Placebo = "grey30", `Caffeine 200 mg` = "grey55"),
                    guide = "none")
ggsave("../figures/09_manuscript_greyscale.png", plot = p_paper_grey,
       width = 160, height = 125, units = "mm", dpi = 320,
       bg = "white", device = ragg::agg_png)

# ---- fig-alternative ----
# Draw the violin, then the raw scores, then the mean and confidence interval.
alt_layers <- list(
  geom_violin(aes(fill = group), width = 0.72, alpha = 0.32, colour = NA,
              trim = TRUE, adjust = 0.9),
  geom_point(aes(colour = group), size = 2.1, alpha = 0.8, stroke = 0,
             position = position_jitter(width = 0.085, height = 0, seed = 3)),
  # This layer uses summ, not the participant-level table.
  geom_errorbar(data = summ, aes(x = group, ymin = mean - ci, ymax = mean + ci),
                inherit.aes = FALSE, width = 0, linewidth = 0.9, colour = "black"),
  # Shape 21 allows a white centre and a separate dark outline.
  geom_point(data = summ, aes(x = group, y = mean), inherit.aes = FALSE,
             shape = 21, size = 3.6, stroke = 0.9, fill = "white", colour = "black"),
  scale_fill_manual(values = ok, guide = "none"),
  scale_colour_manual(values = ok, guide = "none"),
  scale_x_discrete(labels = paste0(levels(dat$group), "\n(n = 40)")),
  score_axis(),
  labs(x = NULL, y = YL)
)

p_alt <- ggplot(dat, aes(x = group, y = vigilance)) + alt_layers +
  labs(title = "Violin with raw data and group mean",
       subtitle = "White circle: group mean. Black bar: 95% confidence interval.") +
  theme_talk_xl
save_fig("12_violin_points_ci.png", p_alt, 5.6, 4.6)

# ---- fig-alternative-journal ----
theme_journal <- theme_talk_xl +
  theme(panel.grid.major.y = element_blank(),
        axis.line  = element_line(colour = ink, linewidth = 0.4),
        axis.ticks = element_line(colour = ink, linewidth = 0.4),
        axis.ticks.length = unit(3.5, "pt"))

# Reuse every data layer and change only the theme.
p_alt_journal <- ggplot(dat, aes(x = group, y = vigilance)) + alt_layers +
  labs(title = "Violin with raw data and group mean",
       subtitle = "Journal theme: drawn axes, no gridlines.") +
  theme_journal
save_fig("12b_violin_points_ci_journal.png", p_alt_journal, 5.6, 4.6)
