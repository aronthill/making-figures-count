# =============================================================================
# A_generate_synthetic_data.R
#
# "Making Figures Count" — Incubator seminar, School of Psychology
# Creates the synthetic dataset used by B_Figure_Pipeline.qmd
#
# THE SCENARIO (entirely fictional)
# --------------------------------
# 80 participants complete a 30-minute sustained attention task after taking
# either a placebo or 200 mg of caffeine. The outcome is a vigilance score
# (0-100; higher = better sustained attention).
#
# The caffeine group is a mixture of two deliberately separated populations.
# Their invented labels (fast and slow metabolisers) support an optional
# example in the guide.
# This is not a model of established caffeine biology. Similar group means can
# conceal different distribution shapes; the SDs already hint at different spread.
# The `metaboliser` column records the labels used to generate the data.
# The main plot sequence uses the treatment groups; the optional example
# adds the subgroup labels. Real plots cannot identify an unmeasured
# biological mechanism on their own.
#
# Requires: base R only. Run once; it writes ../data/caffeine_attention.csv
# Paths are relative to this script's folder - in RStudio use
# Session > Set Working Directory > To Source File Location.
# =============================================================================


# =============================================================================
# 1. Make the example repeatable
# =============================================================================

# The same seed gives the same simulated observations when this script is rerun.
# You can use the supplied CSV without running this script.

set.seed(2026)

n_per_group <- 40

# =============================================================================
# 2. Generate the placebo scores
# =============================================================================
placebo <- data.frame(
  id          = sprintf("P%02d", 1:n_per_group),
  group       = "Placebo",
  metaboliser = NA_character_,
  vigilance   = rnorm(n_per_group, mean = 60, sd = 8)
)

# =============================================================================
# 3. Generate the caffeine scores
# =============================================================================
# These labels and their relationship to scores are fictional. The two
# component distributions make the value of showing distribution shape visible.
n_fast <- 22
n_slow <- n_per_group - n_fast

caffeine <- data.frame(
  id          = sprintf("C%02d", 1:n_per_group),
  group       = "Caffeine 200 mg",
  metaboliser = c(rep("Fast", n_fast), rep("Slow", n_slow)),
  vigilance   = c(rnorm(n_fast, mean = 73, sd = 6),
                  rnorm(n_slow, mean = 50, sd = 6))
)


# =============================================================================
# 4. Combine the groups
# =============================================================================

# Each row represents one participant. The group column will identify the
# treatment in the plots; vigilance is the score on the vertical axis.

dat <- rbind(placebo, caffeine)

# Tidy up: round, clamp to the scale bounds, shuffle row order so the
# structure is not visible from the raw file.
dat$vigilance <- round(pmin(pmax(dat$vigilance, 0), 100), 1)
dat <- dat[sample(nrow(dat)), ]
rownames(dat) <- NULL

# Make sure `group` plots in the intended order downstream.
dat$group <- factor(dat$group, levels = c("Placebo", "Caffeine 200 mg"))

# --- Sanity check printed to the console ------------------------------------
cat("\nGroup summaries (what a table or a bar chart would show you):\n")
print(aggregate(vigilance ~ group, data = dat,
                FUN = function(x) c(n = length(x),
                                    mean = round(mean(x), 2),
                                    sd = round(sd(x), 2))))

cat("\nIndependent-samples t-test:\n")
print(t.test(vigilance ~ group, data = dat))

# --- Write out --------------------------------------------------------------
dir.create("../data", showWarnings = FALSE)
write.csv(dat, "../data/caffeine_attention.csv", row.names = FALSE)
cat("\nWritten to ../data/caffeine_attention.csv\n")
