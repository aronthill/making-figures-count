# Side-by-side comparison of the two themes for the alternative final figure
# (violin + raw observations + group mean with 95% CI), used on slide 12.
#
# The figure itself is defined once, in B_Figure_Pipeline.qmd, and reaches this
# script through the generated B_build_figures.R. Sourcing rather than
# redefining keeps a single definition of the plot.
#
# Run from code/. Requires a B_build_figures.R generated from the current .qmd
# (run C_sync_scripts.R after editing the .qmd).

source("B_build_figures.R")
library(patchwork)

stopifnot(exists("p_alt"), exists("p_alt_journal"))

comparison <-
  (p_alt + labs(title = "Talk theme", subtitle = NULL)) +
  (p_alt_journal + labs(title = "Journal theme", subtitle = NULL))

save_fig("12c_theme_comparison.png", comparison, 11.2, 4.6)

# Choosing between them is a presentation decision, not a data one. Gridlines
# suit a projected slide; drawn axes with tick marks suit most journals. The
# data layers are identical in both.
