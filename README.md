# Process-based lake modeling in R using GLM (General Lake Model)
<a href="url"><img src="GLM_hex.png" align="right" height="220" width="220" ></a>

-----

:busts_in_silhouette: Robert Ladwig, Aryan Adhlakha, Hilary Dugan & Paul Hanson    
:computer: [Material](https://github.com/gsagleon/G21.5_GSA_workshop/tree/master/GLM)  

-----

## Description

The aim of this workshop is (1) to give a general introduction to process-based modeling and GLM-AED2; (2) highlight the application of GLM-AED2 in R (glmtools, GLM3r, LakeEnsemblR); and (3) applying the model to a real-world case, e.g. model calibration, output post-processing and interpreting water quality results. This workshop is intended for all skill levels, although prior knowledge of R is helpful. If you just want to watch, ask questions, and drive from the back seat, that’s fine, too!

## What will this workshop cover?

Introduction to process-based lake modeling:
  - What is process-based modeling?
  - GLM theory and applications
  - AED2 theory and examples for O2 and C
  - Overview of available R-packages

Using the model in R:
  - Running GLM in R
  - Calibrating water temp. and oxygen parameters
  - Visualising results
  - Checking your phytoplankton

Questions and problems:
  - Stick around to talk about questions and raise issues

## Prerequisites

There are two paths to follow the workshop examples:
  # 1. Use Github and your local R setup
  Clone and download files from this [Github repository](https://github.com/robertladwig/GLM_workshop).
  You’ll need R (version >= 3.5), preferably a GUI of your choice (e.g., Rstudio) and these packages:
  ```
  require(devtools)
  devtools::install_packages("GLEON/GLM3r", branch = "GLMv.3.1.0a3")
  devtools::install_packages("hdugan/glmtools", ref = "ggplot_overhaul")
  install.packages("rLakeAnalyzer")
  install.packages("tidyverse")
  ```
  # 2. Use Docker
  To be sure that all the examples will *work* during the workshop, you can use a [container](https://hub.docker.com/r/hydrobert/glm-workshop) of all the material. I'll quote the Docker website here:
  > "A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings."

  You can install the Docker software from [here](https://docs.docker.com/get-docker/). Once installed, you'll need to open a terminal and type (the pulling will take some time depending on your internet connection, it's 3.87 Gb big)
  ```
  docker pull hydrobert/glm-workshop
  docker run --rm -d  -p 8000:8000 -e ROOT=TRUE -e PASSWORD=password hydrobert/glm-workshop:latest
  ```
  Then, open any web browser and type ‘localhost:8000’ and input user: rstudio, and password: password. Rstudio will open up with the script and data available in the file window.

-----
