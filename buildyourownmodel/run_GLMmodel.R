# author: Robert Ladwig
# date: 08/24/2021
# title: Toy GLM model

#### Setup ####
cat("\f")
rm(list = ls())

# if you're using Rstudio:
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# load GLMr3
library(GLM3r)

# check out which R version we're currently using
glm_version()

# run GLM
GLM3r::run_glm(sim_folder = '.', verbose = T)

# overview of files
list.files()

# plot files using GLM functionalities
GLM3r::run_glm(sim_folder = '.', verbose = T, system.args = '--xdisp')
