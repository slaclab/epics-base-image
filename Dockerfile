FROM ubuntu:noble
ARG EPICS_VERSION=R7.0.8.1
ENV EPICS_VERSION=${EPICS_VERSION}
RUN  apt update \
    &&  apt install -y build-essential cmake git tclsh ninja-build gdb lcov libssl-dev libsasl2-dev curl libcurl4-openssl-dev valgrind libicu-dev jq file sudo

RUN git clone --branch $EPICS_VERSION --depth 1 --recursive https://github.com/epics-base/epics-base.git /opt/epics
WORKDIR /opt/epics
RUN make -j 4 INSTALL_LOCATION=/opt/local

#comy form last build to new image
FROM ubuntu:noble
COPY --from=0 /opt/local /opt/local
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      PLATFORM=linux-aarch64; else \
      PLATFORM=linux-amd64; fi && \
      echo "export EPICS_PLATFORM=${PLATFORM}" > /opt/epics-var.sh && \
      echo "export PATH=/opt/local/bin:/opt/local/bin/${PLATFORM}:\$PATH" >> /opt/epics-var.sh && \
      echo "export LD_LIBRARY_PATH=/opt/local/lib:/opt/local/lib/${PLATFORM}:\$LD_LIBRARY_PATH" >> /opt/epics-var.sh