# Image with purely build Python

The image has Python build from cmake into `/opt/python`, in order to have a portable python folder that can be easily moved to another image.

## How to use in multi-stage image build

To use the python built from this image ported to another image, do:

```
FROM ghcr.io/cnts4sci/python:<version> as python-carrier

FROM <your-base-image>

COPY --from=python-carrier /opt/python /opt/python

# You may want to set PYTHON_PATH for your system user of the image
USER <YOU-SYSTEM-USER>

# set up your python path
ENV PATH=/opt/python/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/python/lib:${LD_LIBRARY_PATH}
ENV C_INCLUDE_PATH=/opt/python/include:${C_INCLUDE_PATH}
```
