# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends ffmpeg dvipng cm-super && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install Python 3 packages
RUN conda install --quiet --yes \
    'cloudpickle' \
    'conda-forge::blas=*=openblas' \
    'dask' \
    'ipympl'\
    'ipywidgets' \
    'matplotlib-base' \
    'numba' \
    'pandas' \
    'prefect[viz,templates]' \
    'widgetsnbextension'\
    && conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

WORKDIR "${HOME}"
