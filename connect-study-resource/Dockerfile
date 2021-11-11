FROM r-base

RUN apt-get update && apt-get install libssl-dev
RUN R -e "install.packages('data.table', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('PythonEmbedInR', 'synapser'), repos = c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

COPY build.R /build.R
ENTRYPOINT ["Rscript", "build.R"]
