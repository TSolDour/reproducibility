#Start image from rocker/r-ver:4.5.2
FROM rocker/r-ver:4.5.2

# Create the project folder in the container
WORKDIR /project

# Update linux available libraries and install those necessary.
RUN apt-get update && apt-get install -y \
    curl \
    pandoc \
    libuv1 \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libwebp-dev \
    libcairo2-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libglpk-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto CLI 
ARG QUARTO_VERSION=1.10.18

RUN curl -Ls "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" -o quarto.tar.gz \
    && mkdir -p /opt/quarto \
    && tar -xzf quarto.tar.gz -C /opt/quarto --strip-components=1 \
    && ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto \
    && rm quarto.tar.gz

# During image building, run R and execute the following code.
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"

# Copy files needed for renv::restore() from local project to the container
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# During image building, run R and execute the following code : restore the project's renv library
RUN R -e "renv::restore()"

# Once environment is ok, copy the full project
COPY . .

# Specify where targets is supposed to find its script
ENV TAR_PROJECT=reproducibility

# Execute targets pipeline in the image
RUN R -e "targets::tar_make()"

# Execute targets pipeline when container is executed
CMD ["R", "-e", "targets::tar_make()"]

