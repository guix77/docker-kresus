FROM node:18-bookworm-slim
LABEL maintainer="Thomas Lemarchand"

COPY woob_version /tmp/woob_version
COPY kresus_version /tmp/kresus_version

# Install Woob OS-level dependencies.
# Mundane tasks, all in one to reduce the number of layers:
# - Make sure the UTF-8 locale exists and is used by default.
# - Make sure python3 is used as default python version.
# - Then setup Kresus layout.
# Install Python dependencies.
# Install Kresus.
# Clean everything build related.
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales python3 python3-pip mupdf-tools \
    libnss3-tools python3-nss rustc build-essential && \
    locale-gen C.UTF-8 && \
    update-locale C.UTF-8 && \
    update-alternatives --install /usr/bin/python python $(which python3) 1 && \
    mkdir -p /var/lib/kresus && \
    pip install --break-system-packages --upgrade setuptools && \
    pip install --break-system-packages simplejson BeautifulSoup4 PyExecJS typing-extensions pdfminer.six Pillow woob==`cat /tmp/woob_version` && \
    yarn global add kresus@`cat /tmp/kresus_version` --prefix /opt/kresus --production  && \
    apt-get purge -y python3-pip rustc build-essential && \
    apt-get autoremove --purge -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*;

# Run server.
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOST 0.0.0.0
ENV KRESUS_DIR /var/lib/kresus
ENV NODE_ENV production
ENV KRESUS_PYTHON_EXEC python3

USER node
VOLUME /var/lib/kresus
EXPOSE 9876

ENTRYPOINT ["/opt/kresus/bin/kresus"]
