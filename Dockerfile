FROM registry.cn-huhehaote.aliyuncs.com/shui12366/centos-jdk11

MAINTAINER Apereo Foundation

ENV PATH=$PATH:$JRE_HOME/bin
ARG cas_version=6.1


RUN yum -y install git && yum -y clean all


# Download the CAS overlay project \
RUN cd / \
    && git clone --depth 1 --single-branch -b $cas_version https://github.com/apereo/cas-overlay-template.git cas-overlay \
    && mkdir -p /etc/cas \
    && mkdir -p cas-overlay/bin;

COPY thekeystore /etc/cas/
COPY bin/*.* cas-overlay/
COPY etc/cas/config/*.* /cas-overlay/etc/cas/config/
COPY etc/cas/services/*.* /cas-overlay/etc/cas/services/

RUN chmod 750 /cas-overlay/gradlew \
    && chmod 750 /cas-overlay/*.sh 

EXPOSE 8080 8443

WORKDIR /cas-overlay


RUN mkdir -p ~/.gradle \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
    && ./gradlew clean build --parallel \
    && rm -rf /root/.gradle

CMD ["/cas-overlay/run-cas.sh"]
