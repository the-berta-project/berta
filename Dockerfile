FROM ubuntu:16.04

ARG branch=master
ARG version

ENV name="berta"
ENV spoolDir="/var/spool/${name}"
ENV templateDir="${spoolDir}/template/" \
    logDir="/var/log/${name}"

LABEL application=${name} \
      description="A tool for cleaning opennebula cloud" \
      maintainer="work.dusanbaran@gmail.com" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get --assume-yes upgrade && \
    apt-get --assume-yes install ruby-dev zlib1g-dev gcc patch make gettext-base

RUN gem install ${name} -v "${version}" --no-document

RUN useradd --system --shell /bin/false --home ${spoolDir} --create-home ${name} && \
    usermod -L ${name} && \
    mkdir -p ${templateDir} ${logDir} && \
    chown -R ${name}:${name} ${spoolDir} ${logDir}

VOLUME ${templateDir}

ENTRYPOINT ["berta"]
