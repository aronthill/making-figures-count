# Making Figures Count

Aron Hill — Research Incubator talk.

A guide to making figures in R and ggplot2, using one fictional caffeine and
vigilance dataset. All 80 observations are simulated.

## Included materials

| File | What it is for |
| --- | --- |
| [Illustrated HTML guide](https://aronthill.github.io/making-figures-count/code/B_Figure_Pipeline.html) | Read the explanations and expand the R code beside each figure. |
| [R walkthrough](code/Plot_walkthrough.R) | Work through the setup and plots in one commented script. |
| [Quarto source](code/B_Figure_Pipeline.qmd) | Edit or rebuild the illustrated guide. |
| [Presentation slides](slides/Making_Figures_Count_final_slides.pdf) | View the slides from the talk. |
| [Dataset](data/caffeine_attention.csv) | The simulated scores used in every example. |

## Read the guide

[Read online](https://aronthill.github.io/making-figures-count/), or open
`code/B_Figure_Pipeline.html` in your browser after extracting the download.
The HTML includes its images and styling and works offline. You do not need
R or Quarto to read it.

## Make the figures

1. Extract the ZIP and keep the folder structure intact. The `code/` and
   `data/` folders should remain beside one another.
2. Open `code/Plot_walkthrough.R` in RStudio.
3. Choose **Session → Set Working Directory → To Source File Location**.
4. Run sections **1–3** for packages, data and shared formatting, then work
   through the remaining sections in order. 

Use **Ctrl+Enter** on Windows or **Cmd+Enter** on Mac to run selected lines.
Some plots use objects created earlier. To run the whole script, use:

```r
source("Plot_walkthrough.R")
```

The script requires R 4.1 or later. It uses `ggplot2`, `dplyr` and `ragg`, and
installs missing packages automatically. Package installation needs an
internet connection. Quarto is not needed to run the script.

Type a plot object's name, such as `p_boxpoints`, into the Console to show it
again. Section 16 saves the refined raincloud and narrower violin as PNG and
PDF files in `code/saved_figures/`. Section 4 includes a commented example
for saving an earlier plot.

## Edit the guide

Install Quarto and the R packages `knitr` and `rmarkdown`:

```r
install.packages(c("knitr", "rmarkdown"))
```

Open `code/B_Figure_Pipeline.qmd` in RStudio and click **Render**. The guide
reads its plotting code from `Plot_walkthrough.R`, so keep those files together.
Edit explanations in the Quarto file and plotting code in the R script.
Keep the numbered section headings. If you add or remove a section, also
update the section mapping and corresponding content in the Quarto file.

The R walkthrough contains the complete current code. The slides use shorter
extracts for teaching; follow the walkthrough when recreating the figures.
