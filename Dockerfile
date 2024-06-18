# As build-machine image, it is not actually a runtime
# but I do the runtime multi-stage build to minimize the size
# and for testing the integrity of the openmpi/lapack... static build and move
FROM build-base-image AS python-builder


# Install dependencies for building Python
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
#    libncurses5-dev \
#    libncursesw5-dev \
#    libreadline-dev \
#    libsqlite3-dev \
#    libgdbm-dev \
#    libdb5.3-dev \
#    libbz2-dev \
#    libexpat1-dev \
#    liblzma-dev \
#    tk-dev \
#    libncursesw5-dev \
#    libxml2-dev \
#    libxmlsec1-dev \
#    liblzma-dev \
#    build-essential \
#    wget \
#    curl \
#    llvm \
#    xz-utils \
#    tk-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    cmake \
    make && \
    apt-get clean && rm -rf /var/lib/apt/lists/*



# Download and extract Python source
RUN cd / && git clone https://github.com/python-cmake-buildsystem/python-cmake-buildsystem.git

WORKDIR /python-build

ARG PYTHON_VERSION

RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/python \
    PYTHON_VERSION=${PYTHON_VERSION} \
    BUILD_EXTENSIONS_AS_BUILTIN=ON \
    WITH_STATIC_DEPENDENCIES=ON \
    ../python-cmake-buildsystem && \
    make -j10 && \
    make install

RUN /opt/python/bin/python -m ensurepip --upgrade

# Move binaries to a small image to reduce the size
FROM runtime-base-image

COPY --from=python-builder /opt/python /opt/python

# Test install aiida-core
RUN /opt/python/bin/python -m pip install aiida-core

