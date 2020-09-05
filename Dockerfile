FROM archmixoss/angular

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

#ANDROID STUFF
ENV ANDROID_HOME=/opt/android-sdk-linux

RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y expect ant wget zipalign libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses6 lib32z1 qemu-kvm kmod && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN cd /opt && \
    wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
    tar xzf android-sdk.tgz && \
    rm -f android-sdk.tgz && \
    chown -R root. /opt

ENV GRADLE_VERSION=6.5

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-"$GRADLE_VERSION"-all.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-"$GRADLE_VERSION"-all.zip && \
    rm -rf gradle-"$GRADLE_VERSION"-all.zip

# Setup environment
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/tools:/opt/gradle/gradle-"$GRADLE_VERSION"/bin

# Install sdk elements
COPY tools /opt/tools

RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --no-ui --filter platform-tools,tools,build-tools-29.0.2,android-29,extra-android-support,extra-android-m2repository,extra-google-m2repository"]
RUN unzip ${ANDROID_HOME}/temp/*.zip -d ${ANDROID_HOME}

# -----------------------------------------------------------------------------
# Install Ionic Cli
# -----------------------------------------------------------------------------
RUN \
  npm i -g @ionic/cli

# -----------------------------------------------------------------------------
# Install Cordova
# -----------------------------------------------------------------------------
RUN \
  npm i -g cordova

RUN \
  npm i -g cordova-res --unsafe-perm

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
