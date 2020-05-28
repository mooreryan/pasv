FROM mooreryan/base_images_mafft:7.429 AS mafft-builder
FROM mooreryan/base_images_clustalo:1.2.4 AS clustalo-builder

FROM ruby:2.6.5-buster AS ruby-builder

LABEL maintainer="moorer@udel.edu"

ARG home=/root
ARG downloads=${home}/downloads
ARG ncpus=4
ARG prefix=/opt/pasv
ARG setup_env=${prefix}/setup_env

ENV app_version 1.3.0

WORKDIR ${prefix}

SHELL ["/bin/bash", "-c"]

RUN set -o pipefail && \curl -sSL https://github.com/mooreryan/pasv/archive/v${app_version}.tar.gz | tar xz

RUN mv pasv-${app_version}/* .
RUN chmod 755 pasv

RUN printf "ln -sf ${prefix}/pasv /usr/local/bin\n" > \
           ${prefix}/setup_env

FROM ruby:2.6.5-slim-buster

ARG prefix=/opt/pasv

COPY --from=ruby-builder ${prefix} ${prefix}
COPY --from=clustalo-builder /opt/clustalo /opt/clustalo
COPY --from=mafft-builder /opt/mafft /opt/mafft

WORKDIR ${prefix}

RUN gem install bundler && bundle install

RUN ln -s ${prefix}/pasv /usr/local/bin

# Set up all the things from the builders.
RUN for f in `ls /opt/*/setup_env`; do bash $f; done

CMD ["pasv --help"]
