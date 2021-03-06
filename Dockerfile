ARG  BASE_IMAGE_SUITE=stretch
FROM vicamo/android-pdk:${BASE_IMAGE_SUITE}-openjdk-8

# Re-declare ARG to use it after FROM directive.
ARG BASE_IMAGE_SUITE
ARG USER_NAME=andocker
ARG USER_UID=1000
ARG GROUP_DOCKER_GID

RUN apt-get update --quiet --quiet \
        && apt-get install --no-install-recommends --yes \
                apt-transport-https \
                bash-completion \
                sudo

RUN useradd --comment 'Andocker Development Account' \
                --home /home/${USER_NAME} --create-home \
                --shell /bin/bash \
                --uid ${USER_UID} \
                ${USER_NAME} \
        && (echo "${USER_NAME}:${USER_NAME}" | chpasswd) \
        && adduser ${USER_NAME} sudo \
        && (echo "${USER_NAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME}) \
        && chmod 0440 /etc/sudoers.d/${USER_NAME}

RUN (curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | \
                sudo apt-key add -) \
        && (echo "deb [arch=$(dpkg-architecture -qDEB_BUILD_ARCH)] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") ${BASE_IMAGE_SUITE} $(case ${BASE_IMAGE_SUITE} in artful|buster) echo test;; *) echo stable;; esac)" | \
                tee /etc/apt/sources.list.d/download.docker.com.list) \
        && apt-get update --quiet --quiet \
        && addgroup --system --gid ${GROUP_DOCKER_GID} docker \
        && apt-get install --no-install-recommends --yes \
                docker-ce \
        && adduser ${USER_NAME} docker

ENV USER=${USER_NAME}
WORKDIR /home/${USER_NAME}
User ${USER_NAME}
