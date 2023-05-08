FROM rocker/verse:4.3.0

MAINTAINER Deepak Tanwar (dktanwar@hotmail.com)

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY .bashrc /root/.bashrc
WORKDIR /project

ENV RENV_VERSION 0.17.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e "remotes::install_github('anthonynorth/rscodeio')"

#COPY renv.lock renv.lock
#RUN R -e "renv::restore()"


RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    nano \
    emacs \
    rsync

# Installing Conda
## Thanks: ContinuumIO/docker-images

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet -O ~/miniconda3.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && /bin/bash ~/miniconda3.sh -b -p /opt/conda\
    && rm ~/miniconda3.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    echo "conda activate base" >> ~/.bashrc
ENV PATH /root/miniconda3/bin:$PATH



SHELL ["/bin/bash", "-c"]

#COPY bioinfo.yml .
RUN . /root/.bashrc && \ 
    conda create -n bioinfo -y && \
    conda activate bioinfo

RUN conda install mamba -y    
#RUN mamba env update -n bioinfo --file bioinfo.yml && mamba clean -a -y
#RUN rm /opt/conda/envs/bioinfo/bin/R /opt/conda/envs/bioinfo/bin/Rscript
ENV PATH /opt/conda/envs/bioinfo/bin:$PATH
RUN echo "conda activate bioinfo" >> ~/.bashrc
#RUN mamba install soapec salmon picard trim-galore fastqc trimmomatic bowtie2 soapdenovo2 bcftools bedtools -y

# Installing Tini

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=0.19.0 && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

## automatically link a shared volume for kitematic users
#VOLUME /home/data

RUN mamba install -c bioconda bedtools samtools -y
RUN R -e "install.packages('BiocManager', repos = c(CRAN = 'https://cloud.r-project.org'))"


SHELL ["/bin/bash", "-c"]
ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD [ "/bin/bash" ]
CMD [ "R" ]
CMD [ "/init" ]

## student user
#RUN useradd -m -d /home/student student
#ADD . /home/student/teachingDocker
#RUN chown -R student.student /home/student
RUN mkdir /home/data
#RUN chmod -R 777 /home/data
#RUN chown -R ubuntu.ubuntu /home/data
ENV EDITOR_FOCUS_DIR "/home/data"
RUN mkdir -p "$EDITOR_FOCUS_DIR"
RUN chmod -R 777 /home/data

RUN R -e "BiocManager::install(c('shortRNAhub/shortRNA', 'msa'))"
RUN R -e "BiocManager::install(c('diffUTR'))"
RUN mamba install -c bioconda fastqc multiqc -y
RUN mamba install -c bioconda fastqc multiqc -y
RUN R -e "BiocManager::install(c('dupRadar'))"


#USER student
WORKDIR /home/data

EXPOSE 8787
