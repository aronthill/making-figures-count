# Making Figures Count: synthetic caffeine and attention example
# Generated from B_Figure_Pipeline.qmd by C_sync_scripts.R.
# To maintain this teaching pack, edit the .qmd and regenerate.
# Run from code/ with ../data/caffeine_attention.csv in place.
# Required packages: ggplot2, dplyr, readr, patchwork, ragg, systemfonts.
# Standalone final figure: no prior objects or source() calls required.

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
