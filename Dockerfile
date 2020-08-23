FROM node:12.18.3-buster

# -----------------------------------------------------------------------------
# General dependencies
# -----------------------------------------------------------------------------
RUN \
  apt-get update -qqy && \
  apt-get install -qqy --allow-unauthenticated \
          apt-transport-https \
          software-properties-common \
          curl \
          expect \ 
          zip \
          libsass-dev \
          git \
          sudo


# -----------------------------------------------------------------------------
# Install Java 8
# -----------------------------------------------------------------------------
RUN \
  wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public |  apt-key add - && \
  add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
  apt-get update && \
  apt-get install adoptopenjdk-8-hotspot -qqy

# -----------------------------------------------------------------------------
# Install Android / Android SDK / Android SDK elements
# -----------------------------------------------------------------------------

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/tools

ARG ANDROID_PLATFORMS_VERSION
ENV ANDROID_PLATFORMS_VERSION ${ANDROID_PLATFORMS_VERSION:-25}

ARG ANDROID_BUILD_TOOLS_VERSION
ENV ANDROID_BUILD_TOOLS_VERSION ${ANDROID_BUILD_TOOLS_VERSION:-25.0.3}

RUN \
  echo ANDROID_HOME=${ANDROID_HOME} >> /etc/environment && \
  dpkg --add-architecture i386 && \
  apt-get update -qqy && \
  apt-get install -qqy --allow-unauthenticated\
          gradle  \
          libc6-i386 \
          lib32stdc++6 \
          lib32gcc1 \
          lib32ncurses6 \
          lib32z1 \
          qemu-kvm \
          kmod && \
  cd /opt && \
  mkdir android-sdk-linux && \
  cd android-sdk-linux && \
  curl -SLo sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
  unzip sdk-tools-linux.zip && \
  rm -f sdk-tools-linux.zip && \
  chmod 777 ${ANDROID_HOME} -R  && \
  mkdir -p ${ANDROID_HOME}/licenses && \
  echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license && \
  sdkmanager "tools" && \  
  sdkmanager "platform-tools" && \
  sdkmanager "platforms;android-${ANDROID_PLATFORMS_VERSION}" && \
  sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# -----------------------------------------------------------------------------
# Install Ionic Cli
# -----------------------------------------------------------------------------
RUN \
  npm install -g @ionic/cli

# -----------------------------------------------------------------------------
# WORKDIR is the generic /app folder. All volume mounts of the actual project
# code need to be put into /app.
# -----------------------------------------------------------------------------
WORKDIR /app

# -----------------------------------------------------------------------------
# Ng Dev Server port expose
# -----------------------------------------------------------------------------
EXPOSE 3000

# -----------------------------------------------------------------------------
# Node port expose
# -----------------------------------------------------------------------------
EXPOSE 5000

# -----------------------------------------------------------------------------
# Ionic Dev Server port expose
# -----------------------------------------------------------------------------
EXPOSE 8100

# -----------------------------------------------------------------------------
# Karma port expose
# -----------------------------------------------------------------------------
EXPOSE 9876

# -----------------------------------------------------------------------------
# Live reload port expose
# -----------------------------------------------------------------------------
EXPOSE 35729

# -----------------------------------------------------------------------------
# Start ionic serve.
# -----------------------------------------------------------------------------
CMD ["ionic", "serve", "-b", "--port", "8100", "--host", "0.0.0.0"]
