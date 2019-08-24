FROM jenkins/ssh-slave

LABEL "org.label-schema.vendor"="Roman Dulman" \
    version="1.0" \
    maintainer="romandulman@gmail.com" \
    description=""
      
ARG SDK_VERSION=sdk-tools-linux-4333796.zip
ARG ANDROID_BUILD_VERSION=28
ARG ANDROID_TOOLS_VERSION=28.0.3
ARG BUCK_VERSION=2019.05.22.01
ARG NDK_VERSION=20
ARG WATCHMAN_VERSION=4.9.0
  
# Set up environment variables    
ENV ADB_INSTALL_TIMEOUT=20
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_NDK=/opt/ndk/android-ndk-r$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64  

ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/buck/bin/:${PATH}

RUN apt-get update && apt-get upgrade -y   
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y file gnupg2 unzip apt-transport-https git build-essential curl zip libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists /var/cache/apt
 
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && bash nodesource_setup.sh
RUN apt-get install -y nodejs

# Download Android SDK
 RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
    && mkdir ${ANDROID_HOME} \
    && unzip -q -d ${ANDROID_HOME} /tmp/sdk.zip \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "add-ons;addon-google_apis-google-23" \
        "system-images;android-19;google_apis;armeabi-v7a" \
        "extras;android;m2repository"
 
 # Download Android NDK
RUN curl -sS https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -o /tmp/ndk.zip \
    && mkdir /opt/ndk \
    && unzip -q -d /opt/ndk /tmp/ndk.zip \
    && rm /tmp/ndk.zip
    
 
RUN cd $ANDROID_HOME && wget -q https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -O ndk-bundle.zip && \
    unzip -q ndk-bundle.zip && mv android-ndk-r20 ndk-bundle && chown -R jenkins:jenkins ndk-bundle/
    
# install gcloud
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-230.0.0-linux-x86_64.tar.gz -O g.tar.gz > /dev/null 2>&1 && \
  tar -xvf g.tar.gz > /dev/null 2>&1 && \
  rm -rf g.tar.gz && \
  mkdir -p /opt && \
  mv google-cloud-sdk /opt/google-cloud-sdk && \
  /opt/google-cloud-sdk/install.sh -q > /dev/null 2>&1 && \
  /opt/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true > /dev/null 2>&1

# add gcloud SDK to path
ENV PATH="${PATH}:/opt/google-cloud-sdk/bin/"

RUN npm -g install react-native-cli  
RUN npm -g install karma 
RUN npm -g install mocha 
RUN npm -g install chai 
RUN npm -g install cucumber
RUN npm -g install jest
RUN npm -g install enzyme
