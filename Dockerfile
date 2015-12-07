FROM            ubuntu:14.04

RUN             apt-get -y update
RUN             apt-get install -y nodejs npm curl git
RUN             ln -s /usr/bin/nodejs /usr/bin/node

# Add oracle java 7 repository
RUN             apt-get -y install software-properties-common
RUN             add-apt-repository ppa:webupd8team/java
RUN             apt-get -y update

# Accept the Oracle Java license
RUN             echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections

# Install Oracle Java
RUN             apt-get -y install oracle-java7-installer

ENV             CATALINA_HOME /usr/local/tomcat
ENV             PATH $CATALINA_HOME/bin:$PATH
RUN             mkdir -p "$CATALINA_HOME"
WORKDIR         $CATALINA_HOME

# Install Maven

RUN             sudo mkdir -p /usr/local/apache-maven
RUN             wget http://ftp.wayne.edu/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
RUN             sudo mv apache-maven-3.3.3-bin.tar.gz /usr/local/apache-maven
RUN             sudo tar -xzvf /usr/local/apache-maven/apache-maven-3.3.3-bin.tar.gz -C /usr/local/apache-maven/
RUN             sudo update-alternatives --install /usr/bin/mvn mvn /usr/local/apache-maven/apache-maven-3.3.3/bin/mvn 1
RUN             echo 'export M2_HOME=/usr/local/apache-maven/apache-maven-3.3.3' >> ~/.bashrc
RUN             echo 'export MAVEN_OPTS="-Xms256m -Xmx512m"' >> ~/.bashrc
RUN             echo 'export M2_HOME=/usr/local/apache-maven-3.3.3' >> ~/.bashrc
RUN             echo "Maven is on version `mvn -v`"

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN             gpg --keyserver pool.sks-keyservers.net --recv-keys \
                05AB33110949707C93A279E3D3EFE6B686867BA6 \
                07E48665A34DCAFAE522E5E6266191C37C037D42 \
                47309207D818FFD8DCD3F83F1931D684307A10A5 \
                541FBE7D8F78B25E055DDEE13C370389288584E7 \
                61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
                713DA88BE50911535FE716F5208B0AB1D63011C7 \
                79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
                9BA44C2621385CB966EBA586F72C284D731FABEE \
                A27677289986DB50844682F8ACB77FC2E86E29AC \
                A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
                DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
                F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
                F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV             TOMCAT_MAJOR 7
ENV             TOMCAT_VERSION 7.0.65
ENV             TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN             set -x \
                    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
                    && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
                    && gpg --verify tomcat.tar.gz.asc \
                    && tar -xvf tomcat.tar.gz --strip-components=1 \
                    && rm bin/*.bat \
                    && rm tomcat.tar.gz*


RUN             rm -rf /usr/local/tomcat/webapps/*


RUN             npm install -g bower
RUN             npm install -g grunt-cli

EXPOSE          8080
CMD             ["catalina.sh", "run"]

