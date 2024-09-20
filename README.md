# Analysis of the State of the AnVIL 2024 Poll
Analysis of the State of the AnVIL 2024 Poll

## Purpose
This repository contains the analyses for the State of the AnVIL 2024 Poll and using the [OTTR website template](https://github.com/jhudsl/OTTR_Template_Website) renders a [website that provides an overview of the main results](https://hutchdatascience.org/AnVIL_Poll_2024/) for each section of the poll. That website also provides links to download the poll's questions and possible answers.

## Repository file structure

### root directory `.Rmd` files

* `TidyData.Rmd` -- this `.Rmd` file reads in the raw data using the `googlesheets4` API and then goes through tidying steps such as deduplicating responses based on email, setting simplified column names, recoding responses, etc. Every other `.Rmd` file in the root directory and the `pages` subdirectory depend upon this file and its `resultsTidy` dataframe.
* `anvilPoll2024MainAnalysis.Rmd` -- this `.Rmd` file inherits the `resultsTidy` dataframe from `TidyData.Rmd` and performs the main analyses, saving the preferred plots, for each of the major questions posed in the poll.
* `anvilPoll2024ExtraAnalysis.Rmd` -- This `.Rmd` file inherits the `resultsTidy` dataframe and main analyses from `anvilPoll2024MainAnalysis.Rmd` and runs supplemental analyses and plots extra plots on top of the main analysis.

### other root directory files of importance

* `config_automation.yml` -- this file specifies which docker image to use for this repo (we made a [specific one](https://hub.docker.com/repository/docker/jhudsl/anvil-poll-2024/general) instead of using default) and further turns on/off various OTTR PR check or rendering steps.
* `style.css` -- sets the CSS style for the rendered website.

### data sub-folder

This folder contains 3 codebooks used tidying the data and performing the main analysis.

* `data/codebook.txt` -- This codebook is the main codebook for the project, containing a list of every question in the poll, possible responses, corresponding simplified column names, etc. It's used by `TidyData.Rmd` to set the column names for the tidy data.
* `data/controlledAccessData_codebook.txt` -- This codebook is used within the main analysis to specifically mark which controlled access datasets are currently available on the AnVIL.
* `data/institution_codebook.txt` -- This codebook is used while tidying the data to annotate types of institutional affiliations dependent upon the reported institutional affiliation.

Use of these codebooks was intended to make the analysis code more adaptable for future polls/analyses such that the codebooks can be updated if there are added questions, different institution affiliations, or updates to the data available on the AnVIL, etc.

### plots sub-folder

This sub-folder contains all plots from the analysis (main and extra) in `.png` format.

### pages sub-folder

The `.Rmd` files in this directory are the files that will be rendered to `html` files for the website. This specific behavior is specified in the `.github/workflows/render-site.yml` workflow file and the `resources/render.R` file. The `.Rmd` files within this subdirectory are
  * `index.Rmd` -- the home page of the website
  * `IdentifyTypeOfUsers.Rmd` -- analysis for the first question of the poll that allowed us to identify respondents as either potential or current users of the AnVIL.
  * `Demographics.Rmd` -- analysis for "demographics" related poll questions
  * `Experience.Rmd` -- analysis for "experience" related poll questions
  * `Awareness.Rmd` -- analysis for "awareness" related poll questions
  * `Preferences.Rmd` -- analysis for "preference" related poll questions
  * `CurrentUserQs.Rmd` -- analysis for poll questions asked only to current AnVIL users
  * `contact.Rmd` -- contact information displayed on the website

This directory also contains the `_site.yml` file which defines what pages are where, etc. for the site.

### resources sub-folder

* `scripts/shared_functions.R` -- this file contains functions that are used throughout the various `.Rmd` files for stylizing plots or preparing data.
* `dictionary.txt` -- list of words that the OTTR spell checker shouldn't flag as spelling errors.
* `ignore-urls.txt` -- list of URLs that the OTTR URL checker shouldn't flag as broken.
* `render.R` -- helper script enabling the rendering of materials that rely on the `googlesheets4` API to read in data.  
