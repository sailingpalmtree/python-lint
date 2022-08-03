FROM ubuntu:18.04

# For https://github.com/reviewdog/reviewdog/issues/1158
ENV REVIEWDOG_VERSION=v0.14.1
ENV PYTHON_VERSION=python3.8

RUN apt-get update -y

# Get rid of existing python and pip installations.
RUN apt-get purge python3.? python3-pip -y && apt-get clean || :

# Install wget
RUN apt-get install --no-install-recommends wget git -y
# Clean up apt-get
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install specified Python version and pip3.
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get install -y --no-install-recommends \
    ${PYTHON_VERSION} \
    python3-pip
RUN ${PYTHON_VERSION} -m pip install --no-cache-dir --upgrade pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-distutils \
    python3-setuptools

# Clean up apt-get
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install reviewdog, flake8, pylint and flakeheaven, then plugins for flakeheaven
RUN ${PYTHON_VERSION} -m pip install --no-cache-dir \
    flake8 \
    flakeheaven \
    pylint \
    flake8-bugbear \
    flake8-comprehensions \
    flake8-return \
    flake8-simplify>=0.19.0 \
    flake8-spellcheck \
    flake8-functions \
    wemake-python-styleguide \
    flake8-markdown \
    flake8-docstrings \
    flake8-codes \
    flake8-import-order

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh \
    | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
