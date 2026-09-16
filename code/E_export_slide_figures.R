# Slide versions of the same figures. Run from code/.
# Larger labels and no embedded title leave room for the slide's own message.
# Source first so all plots use the current data and teaching code.
source("B_build_figures.R")
dir.create("../figures/slides", showWarnings = FALSE, recursive = TRUE)
slide_plot <- function(p) p + labs(title = NULL, subtitle = NULL) +
  theme(axis.text = element_text(size = 13, colour = "grey25"),
        axis.title = element_text(size = 13, colour = "grey25"),
        legend.text = element_text(size = 12, colour = "grey25"),
        plot.margin = margin(7, 10, 7, 7))
export_slide <- function(name, p, w, h) {
  ggsave(file.path("../figures/slides", name), p, width = w, height = h,
         dpi = 320, bg = "white", device = ragg::agg_png)
}
export_slide("01_bad_bar.png", p1_bad, 4.6, 3.8)
# Keep panel titles on the axis comparison so the manipulation stays explicit.
export_slide("02_truncated_axis.png", p2, 8.4, 3.8)
export_slide("03_honest_bar.png", slide_plot(p3), 5.2, 4.3)
export_slide("04_boxplot.png", slide_plot(p4), 5.2, 4.3)
export_slide("05_histogram.png", slide_plot(p5) + theme(strip.text = element_text(size = 13)), 5.4, 4.8)
export_slide("06b_violin_box.png", slide_plot(p6b), 5.6, 4.5)
export_slide("07_raincloud.png", slide_plot(p7), 6.2, 4.8)
export_slide("08_reveal.png", slide_plot(p8), 6.2, 5.0)
# The alternative final figure, in both the talk and journal themes.
export_slide("12_violin_points_ci.png", slide_plot(p_alt), 6.2, 4.8)
export_slide("12b_violin_points_ci_journal.png", slide_plot(p_alt_journal), 6.2, 4.8)

# Concrete learning steps used in the revised presentation.
export_slide("06c_points_unjittered.png", slide_plot(p_points0), 5.2, 4.3)
export_slide("06c_points.png", slide_plot(p_points), 5.2, 4.3)
export_slide("06d_points_box.png", slide_plot(p_points_box), 5.2, 4.3)
export_slide("09_manuscript.png", p_paper, 160/25.4, 125/25.4)
export_slide("09_manuscript_greyscale.png", p_paper_grey, 160/25.4, 125/25.4)
# Three aligned views let the presenter explain each raincloud component.
# Keep the point positions, score scale and group labels identical to p7.
p_rain_points <- p7
p_rain_points$layers <- p7$layers[3]
p_rain_box <- p7
p_rain_box$layers <- p7$layers[c(2,3)]
export_slide("07a_rain_points.png", slide_plot(p_rain_points), 6.2, 4.8)
export_slide("07b_rain_points_box.png", slide_plot(p_rain_box), 6.2, 4.8)
# A simple, fixed-bin histogram is easier to explain on the live slide.
p_hist_talk <- ggplot(dat, aes(vigilance, fill = group)) +
  geom_histogram(binwidth = 4, boundary = 0, colour = "white", linewidth = 0.4) +
  facet_wrap(~group, ncol = 1, scales = "fixed") +
  scale_fill_manual(values = ok, guide = "none") +
  labs(x = YL, y = "Participants") + theme_talk +
  theme(strip.text = element_text(size = 13))
export_slide("05_histogram_simple.png", slide_plot(p_hist_talk), 5.4, 4.8)
# The baseline detour uses the same means and 95% CIs as the improved chart.
p_ci_zoom <- p3 +
  scale_y_continuous(limits = c(0, 90), breaks = seq(55, 70, 5),
                     expand = expansion(mult = c(0, 0))) +
  coord_cartesian(ylim = c(55, 70),
                  expand = c(top = FALSE, left = TRUE, bottom = FALSE, right = TRUE))
export_slide("03_honest_bar_zoom.png", slide_plot(p_ci_zoom), 5.2, 4.3)
# Compact panels retain readable labels when three stages share one slide.
compact_points <- function(p) slide_plot(p) +
  scale_x_discrete(labels = c("Placebo", "Caffeine")) +
  scale_y_continuous(breaks = c(40, 60, 80)) +
  labs(y = "Vigilance score", caption = "n = 40 per group") +
  theme(axis.text = element_text(size = 15), axis.title = element_text(size = 15),
        plot.caption = element_text(size = 12, hjust = 0.5),
        plot.margin = margin(8, 8, 5, 5))
export_slide("06c_points_unjittered_compact.png", compact_points(p_points0), 4.0, 4.3)
export_slide("06c_points_compact.png", compact_points(p_points), 4.0, 4.3)
export_slide("06d_points_box_compact.png", compact_points(p_points_box), 4.0, 4.3)
compact_rain <- function(p) slide_plot(p) +
  scale_x_continuous(breaks = 1:2, labels = c("Placebo", "Caffeine"), limits = c(0.72, 2.36)) +
  scale_y_continuous(limits = c(35,85), breaks = c(40,60,80)) +
  labs(y = "Vigilance score", caption = "n = 40 per group") +
  theme(axis.text = element_text(size = 15), axis.title = element_text(size = 15),
        plot.caption = element_text(size = 12, hjust = 0.5),
        plot.margin = margin(8,8,5,5))
export_slide("07a_rain_points_compact.png", compact_rain(p_rain_points), 4.0, 4.3)
export_slide("07b_rain_points_box_compact.png", compact_rain(p_rain_box), 4.0, 4.3)
export_slide("07_raincloud_compact.png", compact_rain(p7), 4.0, 4.3)
