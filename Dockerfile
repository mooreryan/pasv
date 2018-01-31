FROM ruby:2.5-stretch
MAINTAINER Ryan Moore <moorer@udel.edu>

# Copy over the assemblers
WORKDIR /usr/local/bin
COPY vendor/clustalo .
COPY vendor/mafft .

RUN gem install bundler

RUN \curl -sSL https://github.com/mooreryan/pasv/archive/v0.99.0.tar.gz \
    | tar -v -C /home -xz
RUN mv /home/pasv-0.99.0 /home/pasv

WORKDIR /home/pasv
RUN bundle install

CMD ["ruby", "/home/pasv/pasv", "--help"]
