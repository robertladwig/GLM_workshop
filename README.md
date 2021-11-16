# Process-based lake modeling in R using GLM (General Lake Model)
<a href="url"><img src="GLM_hex.png" align="right" height="220" width="220" ></a>

-----

:busts_in_silhouette: Robert Ladwig  
:computer: [Material](https://github.com/robertladwig/GLM_workshop)  
:email: [Questions?](mailto:rladwig2@wisc.edu)
:teacher: [GLEON 21.5 Workshop](https://github.com/gsagleon/G21.5_GSA_workshop/tree/master/GLM), [WSU Workshop](https://github.com/robertladwig/GLM_workshop/blob/master/GLM_workshop_WSU.pdf), [SIL 2021](https://github.com/robertladwig/SIL21_SC07), [GLEON2021 Workshop](https://github.com/robertladwig/GLM_workshop/blob/master/GLM_Workshop_GLEON2021.pdf)

-----

## Description

This workshop material applies the lake model GLM to a real-world case, e.g. model calibration, output post-processing and interpreting water quality results. This workshop is intended for all skill levels, although prior knowledge of R is helpful.

## What will this workshop material cover?

  - Running GLM in R
  - Manipulating the configuration files
  - Visualising the results
  - Calibrating water temp. and oxygen parameters
  - Evaluating effects of external drivers on in-lake processes
  - Checking your phytoplankton

## Prerequisites

### Word of caution
  This workshop example was tested on General Lake Model (GLM) Version 3.1.1. The setup may not work using older and more recent versions of GLM.

  There are two paths to follow the workshop examples. *We recommend the first option (using Docker).*

### 1. Use Docker
   To be sure that all the examples will *work* during the workshop, you can use a [container](https://hub.docker.com/r/hydrobert/glm-workshop) of all the material. I'll quote the Docker website here:

   > "A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings."

   You can install the Docker software from [here](https://docs.docker.com/get-docker/):

   - For Windows users (especially Windows 10 Home), please read the installation instructions on [this site](https://docs.docker.com/docker-for-windows/install-windows-home/). You will need to enable WSL 2 features as described [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and the whole setup can take a while.
   - For Mac users, the installation is pretty and straightforward, please take a look at [this material](https://docs.docker.com/docker-for-mac/install/).
   - You will find an overview of docker installation instructions for most Linux distributions [here](https://docs.docker.com/engine/install/).

     Once installed and started, you'll need to open a terminal and type (the pulling will take some time depending on your internet connection, it's 3.87 Gb big)


    docker pull hydrobert/glm-workshop
    docker run --rm -d  -p 8000:8000 -e ROOT=TRUE -e PASSWORD=password hydrobert/glm-workshop:latest


   Then, open any web browser and type ‘localhost:8000’ and input user: rstudio, and password: password. Rstudio will open up with the script and data available in the file window.

  If you wish to save files on your local computer (everything will disappear once you close the container), you can also run


    docker run --rm -d  -p 8000:8000 -e ROOT=TRUE -e PASSWORD=password -v [LOCAL PATH]:/home/rstudio/workshop/local hydrobert/glm-workshop:latest


   where [LOCAL PATH] would be an existing directory on your machine (e.g., /home/user/docs/glm_workshop_example). Inside the Docker's Rstudio you can then move and copy files to /local to save them on your computer.

   After you have finished the workshop examples, you can close the docker application by running


    docker kill $(docker ps -q)
    docker rm $(docker ps -a -q)


   If you want to deinstall the docker after the workshop, check the docker IMAGE ID by typing:


    docker images -a


   and remove the container by exchanging "IMAGE ID" with the actual one next to your "hydrobert/glm-workshop" container:


    docker rmi "IMAGE ID"

  Here are some more helpful instructions on how to use [docker](https://docs.google.com/document/d/1uxw5aa1gsMpvCBpsGZlaQOkBELR1MJmBQzu4vEKYBoY/edit?usp=sharing).

### 2. Use Github and your local R setup
   Alternatively, you can clone or download files from this [Github repository](https://github.com/robertladwig/GLM_workshop) (click the green "Code" button and select the "Clone" or "Download ZIP" option).
  You’ll need R (version >= 3.5), preferably a GUI of your choice (e.g., Rstudio) and these packages:
  ```
  require(devtools)
  devtools::install_github("robertladwig/GLM3r", ref = "v3.1.1")
  devtools::install_github("USGS-R/glmtools")
  install.packages("rLakeAnalyzer")
  install.packages("tidyverse")
  ```
Update: If the GLM3r installation does not work for you and you're experiencing problems when running ```run_glm()```, then you can try installing:

  ```
  # macOS/Linux
  devtools::install_github("GLEON/GLM3r", ref = "GLMv.3.1.0a3")
  # Windows:
  devtools::install_github("GLEON/GLM3r")
  ```

Windows users will then run v3.1.0a4 whereas Unix users use v3.1.0b1. Unfortunately, some differences between these versions can occur in the model outputs. We are still working on the GLM3r and glmtools packages to keep them updated with new GLM-AED2 releases and to implement new features for model evaluation. This Windows binary sometimes freezes, which can stop the calibration routine. If this happens, please 'stop' the command and re-run it. If you experience problems on macOS (we tested the package only for macOS Catalina) with error messages like 'dyld: Library not loaded', you can also try the following approaches:

   - use and try ``` devtools::install_github("robertladwig/GLM3r", ref = "v3.1.0a3") ``` to install GLM3r
   - or install the missing libraries, e.g. by using ['brew'](https://brew.sh): ``` brew install gcc ```, ``` brew install netcdf```, ``` brew install gc```; afterwards you should install this GLM3r version: ```devtools::install_github("robertladwig/GLM3r", ref = "v3.1.0a3-2")``` (we are working on fixing all these macOS-specific problems)

-----
