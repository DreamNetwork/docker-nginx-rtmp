#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM dockerfile/ubuntu

# Install Nginx with RTMP module
RUN apt-get install git
RUN add-apt-repository -y ppa:nginx/stable &&\
  sed -i 's!# deb-src!deb-src!g' /etc/apt/sources.list.d/nginx-stable-*.list &&\
  cat /etc/apt/sources.list.d/nginx-stable-*.list &&\
  apt-get update
RUN cd /usr/src && git clone git://github.com/arut/nginx-rtmp-module.git nginx-rtmp-module
RUN cd /usr/src && apt-get build-dep nginx -y --force-yes
RUN cd /usr/src && apt-get source nginx
COPY nginx/*.patch /usr/src/

RUN cd /usr/src/nginx-*.*/debian &&\
  sed -i 's!common_configure_flags :=!common_configure_flags := --add-module=/usr/src/nginx-rtmp-module !g' rules
RUN cd /usr/src/nginx-*.*/ &&\
  dpkg-buildpackage -b -j2
RUN mkdir -p /var/log/nginx /var/lib/nginx /var/www/rtmp
RUN cd /usr/src/ &&\
  dpkg -i nginx-common_*.deb nginx-full_*.deb;\
  apt-get install -y --force-yes -f
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/crossdomain.xml /var/www/rtmp/crossdomain.xml
COPY nginx/index.html /var/www/rtmp/index.html
RUN chown -R www-data:www-data /var/lib/nginx

# Clean up
RUN rm -rf /usr/src/nginx* /var/lib/apt/lists/*

# Define mountable directories.
VOLUME ["/etc/nginx/rtmp-enabled", "/etc/nginx/certs", "/var/log/nginx", "/var/www/rtmp"]

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443
EXPOSE 1935
