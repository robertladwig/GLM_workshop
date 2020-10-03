FROM rocker/verse:3.6.3-ubuntu18.04

MAINTAINER  "Robert Ladwig" rladwig2@wisc.edu "ARYAN ADHLAKHA" aryan@cs.wisc.edu

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	gfortran-8 \
	gfortran \
	libgd-dev \
	git \
	build-essential \
	libnetcdf-dev \
	ca-certificates \
	&& update-ca-certificates

RUN 	Rscript -e 'install.packages("ncdf4")' \
	&& Rscript -e 'install.packages("devtools")' \
	&& Rscript -e 'devtools::install_github("GLEON/GLM3r",ref="GLMv.3.1.0a3")' \
	&& Rscript -e 'devtools::install_github("hdugan/glmtools", ref = "ggplot_overhaul")' \
	&& Rscript -e 'devtools::install_github("GLEON/rLakeAnalyzer")' \
	&& Rscript -e 'install.packages("lubridate")' \
	&& Rscript -e 'install.packages("reshape2")' \
	&& Rscript -e 'install.packages("zoo")' \
	&& Rscript -e 'install.packages("ggplot2")' \
	&& Rscript -e 'install.packages("tidyverse")' \

RUN 	echo "rstudio  ALL=(ALL) NOPASSWD:ALL">>/etc/sudoers

RUN	mkdir /home/rstudio/workshop
WORKDIR /home/rstudio/workshop
COPY workshop-glm.R /home/rstudio/workshop/
COPY example /home/rstudio/workshop/
RUN chmod -R 777 .

COPY rserver.conf /etc/rstudio/rserver.conf
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install py-cdrive-api
