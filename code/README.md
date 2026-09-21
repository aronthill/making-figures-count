# Making Figures Count

Aron Hill — Research Incubator talk.

**[Download the complete materials (ZIP)](making-figures-count.zip)**

The ZIP includes the latest guide, R script, presentation slides, simulated
dataset and final figure exports. Extract it before opening the files. Keep
the `code/` and `data/` folders together so the script can find the dataset.

## Files in this folder

- [Read the illustrated guide](B_Figure_Pipeline.html)
- [R walkthrough](Plot_walkthrough.R)
- [Quarto source](B_Figure_Pipeline.qmd)
- [Presentation slides](Making_Figures_Count_final_slides.pptx)

The [online guide](https://aronthill.github.io/making-figures-count/) can be
read without R or Quarto. To recreate the figures, use the complete ZIP above
or download the whole repository using **Code → Download ZIP**. Downloading
only the R file will not include the dataset it needs.

## Run the script

Open `Plot_walkthrough.R` in RStudio, then choose **Session → Set Working
Directory → To Source File Location**. Run sections 1–3 first, then the
remaining sections in order. Some plots build on earlier objects. The script
requires R 4.1 or later and installs any missing plotting packages.

Use **Ctrl+Enter** on Windows or **Cmd+Enter** on Mac to run selected lines.
Alternatively, run everything with `source("Plot_walkthrough.R")`.
Section 16 saves PNG and PDF figures in `saved_figures/`.

The full README inside the ZIP explains how to run the code and rebuild the
guide. The walkthrough is the complete code reference; slides show shorter
extracts for the talk.
