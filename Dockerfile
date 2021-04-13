# First build arg is to ensure pulling the image from the correct repository
# The following will work with any library image that supports multi-arch
# Other repositories may use tag suffix instead
ARG REPO=library
FROM multiarch/qemu-user-static:4.2.0-2 as qemu-user-static

# On some systems, touching a dummy file in the /usr/bin dir doesn't work
# and instead removes all files previously in the directory. Not sure why
# this is happening. Moving everything to a different directory seems to
# work fine though.
RUN mkdir /qemu && touch /qemu/qemu-x86_64-dummy && cp /usr/bin/qemu-* /qemu/

FROM ${REPO}/python:3-alpine

# This should be the target qemu arch
ARG ARCH=x86_64
COPY --from=qemu-user-static /qemu/qemu-${ARCH}-* /usr/bin/

# Everything below here is just a simple example

RUN echo "OK" > /foo

CMD [ "cat", "/foo" ]
