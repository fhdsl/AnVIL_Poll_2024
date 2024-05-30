#!/usr/bin/env Rscript

library(magrittr)
library(tidyverse)

stylize_bar <- function(gplot, usertypeColor = TRUE, singleColor = FALSE, sequentialColor = FALSE){
  if (usertypeColor) {
    fillColors <- c("#E0DD10", "#035C94")
  }
  else if (singleColor){
    fillColors <- c("#25445A")
  }
  else if (sequentialColor){
    fillColors <- c("#035C94","#035385","#024A77","#024168", "#02395B")
  }
  return(
    gplot +
    theme_classic() +
    ylab("") +
    xlab("Count") +
    theme(legend.title = element_blank()) +
    scale_fill_manual(values = fillColors, na.translate = F)
  )
}

stylize_dumbbell <- function(gplot, xmax = NULL, importance = FALSE, preference = FALSE){
  if (importance){
    textGrobMost <- "Most\nimportant"
    textGrobLeast <- "Least\nimportant"
  }
  else if (preference){
    textGrobMost <- "Most\npreferred"
    textGrobLeast <- "Least\npreferred"
  }
  return(
    gplot +
      theme_bw() +
      theme(panel.background = element_blank(),
            legend.position = "bottom",
            legend.title = element_blank()) +
      xlab("Average Rank Choice") +
      ylab("") +
      scale_color_manual(values = c("#E0DD10", "#035C94")) +
      coord_cartesian(clip = "off") +
      theme(plot.margin = margin(1,1,1,1.1, "cm")) +
      scale_x_reverse(limits = c(xmax,1), breaks = xmax:1, labels = xmax:1) +
      annotation_custom(textGrob(textGrobMost, gp=gpar(fontsize=8, fontface = "bold")),xmin=-1,xmax=-1,ymin=-0.5,ymax=-0.5) +
      annotation_custom(textGrob(textGrobLeast, gp=gpar(fontsize=8, fontface= "bold")),xmin=-xmax,xmax=-xmax,ymin=-0.5,ymax=-0.5)
  )
}

prep_df_whichData <- function(subset_df, onAnVILDF = NULL){
  subset_df %<>% separate(AccessWhichControlledData,
                          c("WhichA", "WhichB", "WhichC", "WhichD", "WhichE", "WhichF", "WhichG", "WhichH", "WhichI", "WhichJ", "WhichK", "WhichM", "WhichN"),
                          sep = ", ", fill="right") %>%
    pivot_longer(starts_with("Which"),
                 names_to = "WhichChoice",
                 values_to = "whichControlledAccess") %>%
    drop_na(whichControlledAccess) %>%
    group_by(whichControlledAccess) %>%
    summarize(count = n()) %>%
    mutate(whichControlledAccess =
             recode(whichControlledAccess,
                    "All of Us*" = "All of Us",
                    "UK Biobank*" = "UK Biobank",
                    "Centers for Common Disease Genomics (CCDG)" = "CCDG",
                    "The Centers for Mendelian Genomics (CMG)" = "CMG",
                    "Clinical Sequencing Evidence-Generating Research (CSER)" = "CSER",
                    "Electronic Medical Records and Genomics (eMERGE)" = "eMERGE",
                    "Gabriella Miller Kids First (GMKF)" = "GMKF",
                    "Genomics Research to Elucidate the Genetics of Rare Diseases (GREGoR)" = "GREGoR",
                    "The Genotype-Tissue Expression Project (GTEx)" = "GTEx",
                    "The Human Pangenome Reference Consortium (HPRC)" = "HPRC",
                    "Population Architecture Using Genomics and Epidemiology (PAGE)" = "PAGE",
                    "Undiagnosed Disease Network (UDN)" = "UDN",
                    "Being able to pull other dbGap data as needed." = "Other",
                    "Cancer omics datasets" = "Other",
                    "GnomAD and ClinVar" = "None", #not controlled access
             )
    ) %>%
    left_join(onAnVILDF, by="whichControlledAccess")

  return(subset_df)
}

plot_which_data <- function(inputToPlotDF, subtitle = NULL){

  toreturnplot <- ggplot(inputToPlotDF,
                         aes(
                           x = reorder(whichControlledAccess, -count),
                           y = count,
                           fill = AnVIL_Availability)
                         ) +
    geom_bar(stat="identity") +
    theme_classic() +
    theme(panel.background = element_blank(),
          panel.grid = element_blank(),
          axis.text.x = element_text(angle=45, hjust=1),
          legend.position = "inside",
          legend.position.inside = c(0.8, 0.8)
          ) +
    xlab("Controlled access datasets") +
    ylab("Count") +
    ggtitle("What large, controlled access datasets do you access\nor would you be interested in accessing using the AnVIL?",
            subtitle = subtitle) +
    geom_text(aes(label = after_stat(y), group = whichControlledAccess),
              stat = 'summary',
              fun = sum,
              vjust = -1,
              size=2) +
    coord_cartesian(clip = "off") +
    scale_fill_manual(values = c("#25445A", "#7EBAC0", "grey"))

  return(toreturnplot)
}
