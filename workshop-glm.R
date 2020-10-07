# author: Robert Ladwig
# date: 10/07/2020
# title: GLM Workshop 

#### Workshop setup ####
cat("\f")
rm(list = ls())

# if you're using Rstudio:
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

setwd('./example')

# overview of files for this workshop
list.files()

# install these packages:
# install.packages("devtools")
# require(devtools)
# devtools::install_github("GLEON/GLM3r", ref = "GLMv.3.1.0a3")
# devtools::install_github("hdugan/glmtools", ref = "ggplot_overhaul")
# install.packages("rLakeAnalyzer")
# install.packages("tidyverse")

# we will need these packages
library(glmtools)
library(GLM3r)
library(rLakeAnalyzer)
library(tidyverse)

# overview of glmtools functions
#   | Function       | Title           |
#   | ------------- |:-------------|
#   | `calibrate_sim` | Calibrates GLM-AED2 variables to improve fit between observed and simulated data |
#   | `compare_to_field` | compare metric for GLM vs field observations |
#   | `get_evaporation`  | get evaporation from GLM simulation |
#   | `get_hypsography` | retrieve hypsography information |
#   | `get_ice` | get ice depth from GLM simulation |
#   | `get_nml_value` | gets a nml value according to an arg_name |
#   | `get_surface_height` | get surface height from GLM simulation |
#   | `get_var` | get a variable from a GLM simulation |
#   | `get_wind` | get wind speed from GLM simulation |
#   | `model_diagnostics` | run diagnostics on model results |
#   | `plot_var_compare` | Plot matching heatmaps for modeled and observed variables |
#   | `plot_var_nc` | plot variables from a GLM simulation |
#   | `plot_var_df` | plot variables from a data.frame |
#   | `read_field_obs` | read in field data into a data.frame |
#   | `read_nml` | read in a GLM simulation `*.nml` file |
#   | `resample_sim` | get subset of time from a generic timeseries data.frame |
#   | `resample_to_field` | match GLM water temperatures with field observations |
#   | `set_nml` | sets values in nml object |
#   | `sim_metrics` | get possible metrics for comparing GLM outputs to field |
#   | `summarize_sim` | creates GLM simulation summary outputs |
#   | `validate_sim` | run diagnostics on model results vs observations |
#   | `write_nml` | write GLM `*.nml` for a GLM simulation |

# check out which R version we're currently using
glm_version()

#### Example 1: reading the namelist file into R  ####
glm_template = 'glm3-template.nml' 
sim_folder <- getwd()
out_file <- file.path(sim_folder, "output","output.nc")
field_data <- file.path(sim_folder,"bcs","field_temp_oxy.csv")
file.copy(glm_template, 'glm3.nml', overwrite = TRUE)
nml_file <- file.path(sim_folder, 'glm3.nml')

# read example configuration into memory
eg_nml <- read_nml(nml_file = file.path(sim_folder,'glm3.nml'))
eg_nml
class(eg_nml)
names(eg_nml)
eg_nml[[1]][1:4]

# read and change values inside the namelist file
kw_1 <- get_nml_value(eg_nml, 'Kw')
print(kw_1)

eg_nml <- set_nml(eg_nml, 'Kw', 1.4)
get_nml_value(eg_nml, 'Kw')

eg_nml <- set_nml(eg_nml, 'Kw', kw_1)

# write modified values into namelist file
write_nml(eg_nml, file = nml_file)

#### Example 2: first visualisations ####
# run GLM
GLM3r::run_glm(sim_folder, verbose = T)

# visualize change of water table over time
water_height <- get_surface_height(file = out_file)
ggplot(water_height, aes(DateTime, surface_height)) +
  geom_line() +
  ggtitle('Surface water level') +
  xlab(label = '') + ylab(label = 'Water level (m)') +
  theme_minimal()

# visualize ice formation over time
ice_thickness <- get_ice(file = out_file)
ggplot(ice_thickness, aes(DateTime, `ice(m)`)) +
  geom_line() +
  ggtitle('Ice') +
  xlab(label = '') + ylab(label = 'Ice thickness (m)') +
  theme_minimal()

# visualize change of surface water temp. over time
surface_temp <- get_var(file = out_file, 
                        var_name = 'temp',
                        reference = 'surface',
                        z_out = 2)
ggplot(surface_temp, aes(DateTime, temp_2)) +
  geom_line() +
  ggtitle('Surface water temperature') +
  xlab(label = '') + ylab(label = 'Temp. (deg C)') +
  theme_minimal()

# visualize change of bottom water temp. over time
bottom_temp <- get_var(file = out_file, 
                        var_name = 'temp',
                        reference = 'surface',
                        z_out = 20)
ggplot(bottom_temp, aes(DateTime, temp_20)) +
  geom_line() +
  ggtitle('Bottom water temperature') +
  xlab(label = '') + ylab(label = 'Temp. (deg C)') +
  theme_minimal()

# plot heat maps of water temperature, and compare against observed data
plot_var(nc_file = out_file, 
                 var_name = 'temp')
plot_var_compare(nc_file = out_file, 
                 field_file = field_data, 
                 var_name = 'temp')

# use rLakeAnalyzer to calculate physical derivatives, e.g. thermocline depth
wtr_data <- get_var(file = out_file,
                    var_name = 'temp',
                    reference = 'surface')
str(wtr_data)

wtr_df <- data.frame('datetime' = wtr_data$DateTime,
                     as.matrix(wtr_data[, 2:ncol(wtr_data)]))
colnames(wtr_df) <- c('datetime',paste("wtr_", round(as.numeric(sub(".*_", "", colnames(wtr_df[-1]))),1), sep=""))
td_df <- ts.thermo.depth(wtr = wtr_df, Smin = 0.1, na.rm = TRUE)

ggplot(td_df, aes(datetime, thermo.depth)) +
  geom_line() +
  ggtitle('Thermocline depth') +
  xlab(label = '') + ylab(label = 'Depth (m)') +
  scale_y_continuous(trans = "reverse") + 
  theme_minimal()

#### Example 3: calibrating water temperature parameters ####

temp_rmse <- compare_to_field(nc_file = out_file, 
                              field_file = field_data,
                              metric = 'water.temperature', 
                              as_value = FALSE, 
                              precision= 'hours')

print(paste('Total time period (uncalibrated):',round(temp_rmse,2),'deg C RMSE'))

var = 'temp'         # variable to which we apply the calibration procedure
path = getwd()       # simulation path/folder
nml_file = nml_file  # path of the nml configuration file that you want to calibrate on
glm_file = nml_file # # path of the gml configuration file
# which parameter do you want to calibrate? a sensitivity analysis helps
calib_setup <- data.frame('pars' = as.character(c('wind_factor','lw_factor','ch','sed_temp_mean',
                                                             'sed_temp_mean',
                                                             'coef_mix_hyp','Kw')),
                                     'lb' = c(0.7,0.7,5e-4,3,8,0.6,0.1),
                                     'ub' = c(2,2,0.002,8,20,0.4,0.8),
                                     'x0' = c(1,1,0.0013,5,13,0.5,0.3))
print(calib_setup)
glmcmd = NULL        # command to be used, default applies the GLM3r function
# glmcmd = '/Users/robertladwig/Documents/AquaticEcoDynamics_gfort/GLM/glm'        # custom path to executable
# Optional variables
first.attempt = TRUE # if TRUE, deletes all local csv-files that stores the 
#outcome of previous calibration runs
period = get_calib_periods(nml_file, ratio = 2) # define a period for the calibration, 
# this supports a split-sample calibration (e.g. calibration and validation period)
# the ratio value is the ratio of calibration period to validation period
print(period)
scaling = TRUE       # scaling of the variables in a space of [0,10]; TRUE for CMA-ES
verbose = TRUE
method = 'CMA-ES'    # optimization method, choose either `CMA-ES` or `Nelder-Mead`
metric = 'RMSE'      # objective function to be minimized, here the root-mean square error
target.fit = 2.0     # refers to a target fit of 2.0 degrees Celsius (stops when RMSE is below that)
target.iter = 20    # refers to a maximum run of 20 calibration iterations (stops after that many runs)
plotting = TRUE      # if TRUE, script will automatically save the contour plots
output = out_file    # path of the output file
field_file = field_data # path of the field data
conversion.factor = 1 # conversion factor for the output, e.g. 1 for water temp.

calibrate_sim(var = 'temp', path = getwd(), 
              field_file = field_file, 
              nml_file = nml_file, 
              glm_file = glm_file, 
              calib_setup = calib_setup, 
              glmcmd = NULL, first.attempt = TRUE, 
              period = period, 
              scaling = TRUE, method = 'CMA-ES', metric = 'RMSE', 
              target.fit = 2.0, target.iter = 20, 
              plotting = TRUE, 
              output = output, 
              verbose = TRUE,
              conversion.factor = 1)

#### Example 4: calibrating dissovled oyxgen parameters ####
# Is parameterising water quality feasible using automatic optimization techniques? See: 
# Mi et al 2020: The formation of a metalimnetic oxygen minimum exemplifies how ecosystem dynamics shape biogeochemical processes: A modelling study
# Fenocchi et al 2019: Applicability of a one-dimensional coupled ecological-hydrodynamic numerical model to future projections in a very deep large lake (Lake Maggiore, Northern Italy/Southern Switzerland)

# visualize heat maps of oxygen, phosphate and nitrate
plot_var(nc_file = out_file, 
         var_name = 'OXY_oxy')
plot_var(nc_file = out_file, 
         var_name = 'PHS_frp')
plot_var(nc_file = out_file, 
         var_name = 'NIT_nit')

plot_var_compare(nc_file = out_file, 
                 field_file = field_data, 
                 var_name = 'OXY_oxy',
                 precision = 'hours',
                 conversion = 32/1000)

aed_template = 'aed2/aed2-template.nml' 
file.copy(aed_template, 'aed2/aed2.nml', overwrite = TRUE)
nml_file <- file.path(sim_folder, 'aed2/aed2.nml')
calib_setup <- data.frame('pars' = as.character(c('Fsed_oxy','Ksed_oxy','theta_sed_oxy')),
                          'lb' = c(-150, 10, 1.05),
                          'ub' = c(10,70,1.10),
                          'x0' = c(-100, 50, 1.08))

calibrate_sim(var = 'OXY_oxy', path = getwd(), 
              field_file = field_file, 
              nml_file = nml_file, 
              glm_file = glm_file, 
              calib_setup = calib_setup, 
              glmcmd = NULL, first.attempt = FALSE, 
              period = period, 
              scaling = TRUE, method = 'CMA-ES', metric = 'RMSE', 
              target.fit = 3.0, target.iter = 20, 
              plotting = TRUE, 
              output = output, 
              verbose = TRUE,
              conversion.factor = 32/1000)

# Example 5: check your phytoplankton ####
# Advice for calibrating phytoplankton functional groups, investigate the
# limitation functions; this example setup is not completely set up for 
# intensive water quality calculations --> this is just an example how to do it
aed_nml <- read_nml('aed2/aed2.nml')

# heat maps of phosphate, nitrate and silica
plot_var(nc_file = out_file, var_name = 'PHS_frp',reference = 'surface')
plot_var(nc_file = out_file, var_name = 'NIT_nit',reference = 'surface')
plot_var(nc_file = out_file, var_name = 'SIL_rsi',reference = 'surface')

# heat maps of cyanobacteria and diatoms
plot_var(nc_file = out_file, var_name = 'PHY_cyano',reference = 'surface')
plot_var(nc_file = out_file, var_name = 'PHY_diatom', reference = 'surface')

# visualize change of surface cyanobacteria over time
surface_cyano <- get_var(file = out_file, 
                        var_name = 'PHY_cyano',
                        reference = 'surface',
                        z_out = 2)
ggplot(surface_cyano, aes(DateTime, PHY_cyano_2)) +
  geom_line() +
  ggtitle('Cyanobacteria functional group') +
  xlab(label = '') + ylab(label = '(mmol/m3)') +
  theme_minimal()

# visualize change of surface diatoms over time
surface_diatom <- get_var(file = out_file, 
                         var_name = 'PHY_diatom',
                         reference = 'surface',
                         z_out = 2)
ggplot(surface_diatom, aes(DateTime, PHY_diatom_2)) +
  geom_line() +
  ggtitle('Diatoms functional group') +
  xlab(label = '') + ylab(label = '(mmol/m3)') +
  theme_minimal()

phyto_list <- get_nml_value(aed_nml,arg_name = 'aed2_phytoplankton::dbase')

path_phyto <- phyto_list
phyto_nml <- read_nml(path_phyto)
phyto_nam <- get_nml_value(phyto_nml,arg_name = 'pd%p_name')
names <- unlist(strsplit(phyto_nam, ","))

lim_attributes <- c('fI', 'fNit', 'fPho', 'fSil', 'fT', 'fSal')
plist <- list()
pindex <- 1
for (ii in seq_len(length(names))){
  for (jj in seq_len(length(lim_attributes))){
    
    p1 <- plot_var(nc_file = out_file, var_name = paste0('PHY_',names[ii],'_',
                                                         lim_attributes[jj]),
                   legend.title = paste(names[ii], lim_attributes[jj]))
    
    plist[[pindex]] <- p1
    pindex <- pindex + 1
  }
}

# limitation functions for cyanobacteria and diatoms
p_cyano <- plist[[1]] / plist[[2]] / plist[[3]] / plist[[4]] / plist[[5]] / plist[[6]] 
p_diatom <- plist[[7]] / plist[[8]] / plist[[9]] / plist[[10]] / plist[[11]] / plist[[12]] 

p_cyano
p_diatom
