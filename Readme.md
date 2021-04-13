# multiarch-pipeline-test

This is a test repo that serves as an example of publishing multi-arch Docker builds with Drone.

You can check the descriptions of each file below.

Builds from this pipeline are deployed to Docker Hub for validation as [IamTheFij/multiarch-pipeline-test](https://hub.docker.com/r/iamthefij/multiarch-pipeline-test).

## File descriptions

### Makefile

This file is optional, but I like to use a `Makefile` to simplify iteration while on my local machine. There are comments inline, but the example is configured to set up a few simple targets for building and running images and containers for various target architechtures. It takes advantage of the depenency system in `make` to ensure the required `qemu` binaries are downloaded only one time to avoid uneeded http requests.

### Dockerfile

This is the root of the "magic". This file includes inline documentation as well describing it's usage. Essentially, using a few `buildargs`, we can specify the base image and the `qemu` binary to include at build time.

Many library images now [support multiple architechtures](https://github.com/docker-library/official-images#architectures-other-than-amd64) and do so by providing them under a different prefix repo.

However, some images use a tag suffix format. In fact, that will be the output of this pipeline. Something like `user/image:linux-amd64` and `user/image:linux-arm`, etc. It's still possible to build based on those images. To do so, instead of a `REPO` arg, you can rename it to `TAG_SUFFIX` and update the `FROM` statement in the `Dockerfile` to something like `FROM user/image:1.0.0-${TAG_SUFFIX}`.

If you do rename the build arg, you must also rename the arg in the `Makefile` and `.drone.yml`.

### .drone.yml

This is the build pipeline that Drone uses. Right now it's set up to run tests on all pushes and tags and then build and publish images on any tag or when a commit is pushed to `master`.

This is done by using distinct pipelines for each of these processes. First is the `test` pipeline, since we don't want to publish anything unless tests have passed.

After that, there are three distinct pipelines that can be run in parallel. One for each arch we would like to support. They are `linux-amd64`, `linux-arm`, and `linux-arm64`. These have two build steps. First to download the proper `qemu` binary, and second to build and push the image to Docker Hub. We take advantage of the autotagging feature of the Drone plugin to get convenient Docker image tags to match our git tags.

Once all three complete successfully, a final pipeline generates a Docker manifest and pushes it to Docker Hub. This allows Docker will map a client architechture to a particular Docker image. After this is pushed you should be able to `docker run user/image` on any of our supported architechtures and Docker will pull the correct image.
