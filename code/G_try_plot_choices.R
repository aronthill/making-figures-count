# Optional standalone exercises retained from the original teaching pack.
# Run from code/. Requires ggplot2 only.
# Run from code/. Change one setting at a time and compare the results.
library(ggplot2)
dat <- read.csv("../data/caffeine_attention.csv")
dat$group <- factor(dat$group, levels = c("Placebo", "Caffeine 200 mg"))
p_jitter <- ggplot(dat, aes(group, vigilance)) +
  geom_point(alpha = 0.7,
             position = position_jitter(width = 0.10, height = 0, seed = 1)) +
  labs(x = NULL, y = "Vigilance score (0-100)") + theme_minimal()
print(p_jitter)
p_hist <- ggplot(dat, aes(vigilance)) +
  geom_histogram(binwidth = 4, boundary = 0, colour = "white", fill = "grey45") +
  facet_wrap(~group, ncol = 1, scales = "fixed") +
  labs(x = "Vigilance score (0-100)", y = "Participants") + theme_minimal()
print(p_hist)
p_violin <- ggplot(dat, aes(group, vigilance)) +
  geom_violin(adjust = 0.8, trim = TRUE, fill = "grey85") +
  geom_point(size = 1.5, alpha = 0.6,
             position = position_jitter(width = 0.08, height = 0, seed = 1)) +
  labs(x = NULL, y = "Vigilance score (0-100)") + theme_minimal()
print(p_violin)
