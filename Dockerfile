FROM jenkins/ssh-slave

LABEL "org.label-schema.vendor"="Roman Dulman" \
    version="1.0" \
    maintainer="roman.dulman@opotel.com" \
    description=""
    
RUN apt-get update && apt-get upgrade -y   
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y file git curl zip libncurses5:i386 libstdc++6:i386 zlib1g:i386 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists /var/cache/apt
 
RUN curl -sSL https://get.docker.com/ | sh
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && bash nodesource_setup.sh
RUN apt-get install -y nodejs

# Set up environment variables
ENV ANDROID_HOME="/opt/android-sdk-linux" \
    SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    GRADLE_URL="https://services.gradle.org/distributions/gradle-4.5.1-all.zip"

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
 && cd "$ANDROID_HOME" \
 && curl -o sdk.zip $SDK_URL \
 && unzip sdk.zip \
 && rm sdk.zip \
 && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Install Gradle
RUN wget $GRADLE_URL -O gradle.zip \
 && unzip gradle.zip \
 && mv gradle-4.5.1 gradle \
 && rm gradle.zip \
 && mkdir .gradle
 
RUN cd $ANDROID_HOME && wget -q https://dl.google.com/android/repository/android-ndk-r15c-linux-x86_64.zip -O ndk-bundle.zip && \
    unzip -q ndk-bundle.zip && mv android-ndk-r15c ndk-bundle && chown -R jenkins:jenkins ndk-bundle/
    
ENV PATH="/home/user/gradle/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}"

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
RUN npm -g install pm2@latest 
RUN npm -g install typescript
RUN npm -g install nodemon
RUN npm -g install karma 
RUN npm -g install mocha 
RUN npm -g install chai 
RUN npm -g install cucumber
RUN npm -g install jest
RUN npm -g install enzyme
RUN npm -g install artillery --unsafe-perm=true --allow-root
RUN npm -g install selenium-webdriver
