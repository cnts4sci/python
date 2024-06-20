# As build-machine image, it is not actually a runtime
# but I do the runtime multi-stage build to minimize the size
# and for testing the integrity of the openmpi/lapack... static build and move
FROM build-base-image AS python-builder


# Install dependencies for building Python
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    # cmake can be removed after bm:2024:1002
    cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and extract Python source
RUN cd / && git clone https://github.com/python-cmake-buildsystem/python-cmake-buildsystem.git

WORKDIR /python-build

# Build a static sqlite3 lib
RUN wget -c -O sqlite.tar.gz https://www.sqlite.org/2024/sqlite-autoconf-3460000.tar.gz && \
    mkdir -p sqlite && \
    tar xf sqlite.tar.gz -C sqlite --strip-components=1 && \
    cd sqlite && \
    ./configure CPPFLAGS="$CPPFLAGS -fPIC" -enable-static --disable-shared && \
    make && \
    make install

ARG PYTHON_VERSION

RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/python \
    PYTHON_VERSION=${PYTHON_VERSION} \
    BUILD_EXTENSIONS_AS_BUILTIN=ON \
    WITH_STATIC_DEPENDENCIES=ON \
    ../python-cmake-buildsystem && \
    make -j10 && \
    make install

RUN /opt/python/bin/python -m ensurepip --upgrade && \
    ln -s /opt/python/bin/pip3 /opt/python/bin/pip

# Move binaries to a small image to reduce the size
FROM runtime-base-image

COPY --from=python-builder /opt/python /opt/python

ENV PATH=/opt/python/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/python/lib:${LD_LIBRARY_PATH}
ENV C_INCLUDE_PATH=/opt/python/include:${C_INCLUDE_PATH}
