FROM ubuntu:18.04
# docker build -t swift:rxswift-linux-5.0.1 scripts
ENV swift=5.0.1
ENV PATH=${PATH}:/tmp/swift-${swift}-RELEASE-ubuntu18.04/usr/bin
RUN /bin/bash -c "set -e; echo \"Installing swift ${swift}\"; apt-get update && apt-get install -y curl clang libicu-dev libbsd-dev git && curl -v \"https://swift.org/builds/swift-${swift}-release/ubuntu1804/swift-${swift}-RELEASE/swift-${swift}-RELEASE-ubuntu18.04.tar.gz\" > /tmp/swift.tar.gz; tar -xzf /tmp/swift.tar.gz -C /tmp; swift -version;"
