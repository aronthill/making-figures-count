# Regenerate the downloadable scripts from B_Figure_Pipeline.qmd.
# Run from code/. Uses base R only. Rendering the handout calls this too.
lines <- readLines("B_Figure_Pipeline.qmd", warn = FALSE, encoding = "UTF-8")
starts <- which(grepl("^```\\{r\\}$", lines))
chunks <- list()
for (start in starts) {
  end <- start + which(lines[(start + 1):length(lines)] == "```")[1]
  body <- lines[(start + 1):(end - 1)]
  label <- sub("^#\\| label: ", "", body[grepl("^#\\| label: ", body)])
  if (length(label) == 1L) {
    chunks[[label]] <- body[!grepl("^#\\|", body)]
  }
}
figure_labels <- c("fig-badbar", "fig-truncated", "fig-honestbar", "fig-boxplot",
                   "fig-histogram", "fig-violin", "fig-violinbox", "fig-points",
                   "fig-raincloud", "fig-reveal", "fig-manuscript",
                   "fig-alternative", "fig-alternative-journal")
stopifnot(all(c("setup", figure_labels) %in% names(chunks)))
# Bare plot expressions are for Quarto's inline display. Omit them in exported
# scripts so Rscript does not open an implicit PDF device before ggsave().
display_only <- c("p1_bad", "p2", "p3", "p4", "p5", "p6", "p6b",
                  "p_points_sequence", "p7", "p8", "p_paper", "p_effect", "p_bins",
                  "p_alt", "p_alt_journal")
assemble <- function(labels) {
  unlist(lapply(labels, function(label) {
    code <- chunks[[label]]
    code <- code[!trimws(code) %in% display_only]
    c(paste0("\n# ---- ", label, " ----"), code)
  }), use.names = FALSE)
}
header <- c("# Making Figures Count: synthetic caffeine and attention example",
            "# Generated from B_Figure_Pipeline.qmd by C_sync_scripts.R.",
            "# To maintain this teaching pack, edit the .qmd and regenerate.",
            "# Run from code/ with ../data/caffeine_attention.csv in place.",
            "# Required packages: ggplot2, dplyr, readr, patchwork, ragg, systemfonts.")
writeLines(c(header, assemble(c("setup", figure_labels))), "B_build_figures.R", useBytes = TRUE)
writeLines(c(header, "# Standalone final figure: no prior objects or source() calls required.",
             assemble(c("setup", "fig-raincloud", "fig-manuscript"))), "D_final_raincloud.R", useBytes = TRUE)
# Keep the publication caption available as a plain text file too.
start <- starts[vapply(starts, function(i) identical(lines[i + 1], "#| label: fig-raincloud"), logical(1))]
cap_start <- start + which(lines[(start + 1):length(lines)] == "#| fig-cap: |")[1]
caption <- sub("^#\\|   ", "", lines[cap_start + 1])
dir.create("../figures", showWarnings = FALSE)
writeLines(caption, "../figures/07_raincloud_caption.txt", useBytes = TRUE)

# The starter has independent imports and only requires ggplot2.
writeLines(c("# Generated from the starter chunk in B_Figure_Pipeline.qmd.",
             "# Run from code/. Requires ggplot2 only.", chunks[["starter"]]),
           "F_starter_plot.R", useBytes = TRUE)
