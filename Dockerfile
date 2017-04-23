FROM resin/rpi-raspbian:wheezy
MAINTAINER Patrick Wagstrom <patrick@wagstrom.net>

ENV CRASHPLAN_VERSION 4.8.0
ENV JAVA_VERSION jdk1.8.0_112

RUN apt-get update && apt-get install -y wget tightvncserver xfonts-base libswt-gtk-3-java libswt-cairo-gtk-3-jni

RUN cd /tmp && \
    wget --no-cookies \
        --no-check-certificate \
        --header "Cookie: oraclelicense=accept-securebackup-cookie" \
        "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-arm32-vfp-hflt.tar.gz" \
        -O jdk-8u121-linux-arm32-vfp-hflt.tar.gz && \
    cd /usr/local && \
    tar -zxvf /tmp/jdk-8u121-linux-arm32-vfp-hflt.tar.gz && \
    cd /tmp && \
    rm -rf jdk-8u121-linux-arm32-vfp-hflt.tar.gz

RUN cd /tmp && \
    wget https://download2.code42.com/installs/linux/install/CrashPlan/CrashPlan_${CRASHPLAN_VERSION}_Linux.tgz -O crashplan.tgz && \
    tar -zxvf crashplan.tgz && \
    cd crashplan-install && \
    sed -i.bak 's|JAVACOMMON="DOWNLOAD"|JAVACOMMON="/usr/local/jdk1.8.0_112/bin/java"|' install.sh && \
    yes '' | ./install.sh && \
    cd /usr/local/crashplan && \
    wget http://www.jonrogers.co.uk/wp-content/uploads/2012/05/libjtux.so -O libjtux.so && \
    wget http://www.jonrogers.co.uk/wp-content/uploads/2012/05/libmd5.so -O libmd5.so && \
    cp /usr/lib/java/swt-gtk-3.8.0.jar /usr/local/crashplan/lib/org.eclipse.swt.gtk.linux.x86.jar && \
    rm -rf /tmp/crashplan.tgz /tmp/crashplan-install

RUN update-alternatives --install /usr/bin/java java /usr/local/$JAVA_VERSION/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /usr/local/$JAVA_VERSION/bin/javac 1 && \
    update-alternatives --config javac && \
    echo 2 | update-alternatives --config java && \
    update-rc.d crashplan defaults

VOLUME /backup /config
EXPOSE 4243 4242 5901
