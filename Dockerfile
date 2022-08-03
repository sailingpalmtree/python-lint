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
# TODO(balint) this seems to break later pip commands: "/usr/bin/pip not found"
# RUN ${PYTHON_VERSION} -m pip install --no-cache-dir --upgrade pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-distutils \
    python3-setuptools

# Clean up apt-get
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install flake8, pylint and flakeheaven, then plugins for flakeheaven
RUN ${PYTHON_VERSION} -m pip install --no-cache-dir \
    flake8==4.0.1 \
    pylint>=2.15.0 \
    flakeheaven>=3.0.0 \
    flake8-bugbear>=22.7.1 \
    flake8-comprehensions>=3.10.0 \
    flake8-return>=1.1.3 \
    flake8-simplify>=0.19.3 \
    flake8-spellcheck>=0.28.0 \
    flake8-functions>=0.0.7 \
    wemake-python-styleguide>=0.16.1 \
    flake8-markdown>=v0.3.0 \
    flake8-docstrings>=1.6.0 \
    flake8-codes>=0.2.2 \
    flake8-import-order>=0.18.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh \
    | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
