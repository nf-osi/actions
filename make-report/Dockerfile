FROM ghcr.io/nf-osi/nfportalutils:develop

WORKDIR /build

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common \
    pandoc

RUN R -e "install.packages(c('rmarkdown', 'reactable', 'htmltools'), dependencies = c('Depends', 'Imports'), repos='http://cran.rstudio.com/')"

ENTRYPOINT ["make"]
CMD ["--help"]
