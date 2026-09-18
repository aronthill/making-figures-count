# Making Figures Count

Aron Hill — School of Psychology research incubator talk.

A practical guide to making figures in R and ggplot2, using a fictional caffeine and vigilance study. All 80 observations and the subgroup labels are synthetic teaching data.

## Read the guide

Download this repository using **Code → Download ZIP**, then extract the ZIP. Open `code/B_Figure_Pipeline.html` in your browser. You do not need R or Quarto to read it. Expand **Show R code** to see how each figure was made.

## Run the code

1. Keep the folders together. In RStudio, open `code/F_starter_plot.R` and choose **Session → Set Working Directory → To Source File Location**.
2. Install ggplot2 once by running `install.packages("ggplot2")` in the Console.
3. Run the starter script. It reads the supplied CSV and saves a plot in `figures/`.

For the full figure sequence, install these packages once:

```r
install.packages(c("ggplot2", "dplyr", "readr", "patchwork", "ragg", "systemfonts"))
```

Then open and run `code/B_build_figures.R`, using the same working-directory setting. It writes the figures to `figures/`. Use R 4.1 or later; figure fonts may vary between computers.

## Files

| File or folder | Contents |
| --- | --- |
| `code/B_Figure_Pipeline.qmd` | Quarto source: explanations and plotting code |
| `code/B_Figure_Pipeline.html` | Illustrated guide, ready to read offline |
| `code/pipeline.css` | Formatting for the HTML guide |
| `data/caffeine_attention.csv` | Synthetic data: ID, group, metaboliser label and vigilance score |
| `code/F_starter_plot.R` | Short first example using only ggplot2 |
| `code/B_build_figures.R` | All figures in the guide, without Quarto |
| `code/D_final_raincloud.R` | Independent raincloud and manuscript exports |
| `figures/` | Supplied figure images, including supplementary and slide versions |
| `presentation/` | PowerPoint slides and presenter notes |
| `assets/fonts/` | Optional slide fonts and their licences |

Other scripts in `code/` generate the synthetic data (A), synchronise scripts with the Quarto source (C), export slide figures (E), try simple plotting changes (G), and compare two themes (H). You can ignore these when starting.

## Edit the guide

Install [Quarto](https://quarto.org/) and the R package `knitr`, as well as the packages above. Open `code/B_Figure_Pipeline.qmd` in RStudio and click **Render**. Keep `pipeline.css` and `C_sync_scripts.R` beside it. Rendering updates the HTML, figures and generated B, D and F scripts; edit their code in the Quarto source.

To use your own data, change the CSV import and column names in `aes()`. Check units, missing values, group sizes and axis ranges. The fixed labels and limits here belong to this teaching example.

