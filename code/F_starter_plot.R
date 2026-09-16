# Generated from the starter chunk in B_Figure_Pipeline.qmd.
# Run from code/. Requires ggplot2 only.
# Install ggplot2 once if needed: install.packages("ggplot2")
library(ggplot2)
# Run from code/ so this path finds the supplied CSV.
dat <- read.csv("../data/caffeine_attention.csv")
# Set the left-to-right order of the groups.
dat$group <- factor(dat$group, levels = c("Placebo", "Caffeine 200 mg"))
# Put group on the x-axis and each participant’s score on the y-axis.
p <- ggplot(dat, aes(x = group, y = vigilance)) +
# Move points sideways only. The seed keeps their positions repeatable.
  geom_point(position = position_jitter(width = 0.10, height = 0, seed = 1),
             alpha = 0.7) +
  labs(x = NULL, y = "Vigilance score (0-100)") +
  theme_minimal(base_size = 12)
print(p)
dir.create("../figures", showWarnings = FALSE)
# Save at a specified physical size, then check that the labels are readable.
ggsave("../figures/starter_points.png", plot = p,
       width = 160, height = 115, units = "mm", dpi = 320, bg = "white")
