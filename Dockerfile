#
# Couchbase Dockerfile
#

# Pull base image
FROM ubuntu:12.04

# User limits
RUN sed -i.bak '/\# End of file/ i\\# Following 4 lines added by docker-couchbase-server' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                hard    memlock          unlimited' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                soft    memlock         unlimited\n' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                hard    nofile          65536' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                soft    nofile          65536\n' /etc/security/limits.conf
RUN sed -i.bak '/\# end of pam-auth-update config/ i\\# Following line was added by docker-couchbase-server' /etc/pam.d/common-session
RUN sed -i.bak '/\# end of pam-auth-update config/ i\session	required        pam_limits.so\n' /etc/pam.d/common-session

# Locale
RUN locale-gen en_US en_US.UTF-8

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install vim wget curl libssl1.0.0 librtmp0 python && \
  wget http://packages.couchbase.com/releases/3.0.0/couchbase-server-community_3.0.0-ubuntu12.04_amd64.deb -O couchbase-server-community_3.0.0-ubuntu12.04_amd64.deb && \
  dpkg -i couchbase-server-community_3.0.0-ubuntu12.04_amd64.deb && \
  rm couchbase-server-community_3.0.0-ubuntu12.04_amd64.deb

# Expose Web Administration Port, Couchbase API Port & Internal/External Bucket Port
EXPOSE 4369 8080 8091 8092 11207 11208 11209 11210 11211 11212 11213 11214 11215 21100 21101 21102 21103 21104 21105 21106 21107 21108 21109 21110 21111 21112 21113 21114 21115 21116 21117 21118 21119 21120 21121 21122 21123 21124 21125 21126 21127 21128 21129 21130 21131 21132 21133 21134 21135 21136 21137 21138 21139 21140 21141 21142 21143 21144 21145 21146 21147 21148 21149 21150 21151 21152 21153 21154 21155 21156 21157 21158 21159 21160 21161 21162 21163 21164 21165 21166 21167 21168 21169 21170 21171 21172 21173 21174 21175 21176 21177 21178 21179 21180 21181 21182 21183 21184 21185 21186 21187 21188 21189 21190 21191 21192 21193 21194 21195 21196 21197 21198 21199

ADD start-couchbase.sh /start-couchbase.sh
ADD check-cluster.py /check-cluster.py
RUN chmod 755 /start-couchbase.sh
RUN chmod 755 /check-cluster.py

# start couchbase
CMD ["/start-couchbase.sh"]