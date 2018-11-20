# 1) O/S part
FROM docker-dev.artifactory.service.altiscale.com/hercules
WORKDIR /root

RUN groupadd -g 500 jenkins-slave
RUN useradd -u 500 -g 500 -ms /bin/bash jenkins-slave
RUN mkdir -p /home/jenkins-slave/build
RUN chown jenkins-slave:jenkins-slave /home/jenkins-slave/build
ENV DOCKER_WORKSPACE /home/jenkins-slave/build

# 2) install packages for apache spark compile
# Install common dependencies for packages
RUN curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo && \
    yum clean all && \
    rpm --rebuilddb && \
    yum install -y java-1.8.0-openjdk-devel \
    git \
    cmake \
    apache-maven \
    rubygems \
    ruby-devel \
    ruby \
    scala \
    vcc-buildtools \
    scala \
    sbt
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0
ENV MAVEN_HOME /usr/share/apache-maven
ENV M2_HOME /usr/share/apache-maven
ENV PATH $PATH:/usr/share/apache-maven/bin:/opt/apache-maven/bin

# 3) Set the compile environment (configuration)


# Install Ruby 2.4.1 dependency
# Reference: https://gist.github.com/mustafaturan/8290150
RUN yum -y install libxslt-devel \
    libyaml-devel \
    libxml2-devel \
    gdbm-devel \
    libffi-devel \
    zlib-devel \
    openssl-devel \
    readline-devel \
    curl-devel \
    pcre-devel

# Install Ruby 2.4.1
RUN cd /usr/local/src && wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz && \
    tar zxvf ruby-2.4.1.tar.gz && \
    cd ruby-2.4.1 && \
    ./configure && make && make install

RUN cd /usr/local/src && wget https://rubygems.org/rubygems/rubygems-2.6.12.tgz && \
    tar zxvf rubygems-2.6.12.tgz && cd rubygems-2.6.12 && \
    /usr/local/bin/ruby setup.rb --no-document && \
    gem install bundler

# Install required gem for building rpm
RUN /bin/bash -l -c "gem install fpm"

