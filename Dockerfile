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
	&& Rscript -e 'devtools::install_github("robertladwig/GLM3r",ref="v3.1.1")' \
	&& Rscript -e 'devtools::install_github("USGS-R/glmtools")' \
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
RUN chmod -R 777 .
COPY example /home/rstudio/workshop/example
WORKDIR /home/rstudio/workshop/example
RUN chmod -R 777 .
COPY buildyourownmodel /home/rstudio/workshop/buildyourownmodel
WORKDIR /home/rstudio/workshop/buildyourownmodel
RUN chmod -R 777 .

COPY rserver.conf /etc/rstudio/rserver.conf
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install py-cdrive-api
