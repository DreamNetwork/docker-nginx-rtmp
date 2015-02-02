#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM dockerfile/ubuntu

# Install Nginx with RTMP module
RUN apt-get install git
RUN add-apt-repository -y ppa:nginx/stable && apt-get update
RUN cd /usr/src && git clone git://github.com/arut/nginx-rtmp-module.git nginx-rtmp-module
RUN cd /usr/src && apt-get build-dep nginx -y --force-yes && apt-get source nginx
COPY nginx/*.patch /usr/src/
RUN cd /usr/src/nginx-*.*/ && patch -p1 < ../*.patch && rm ../*.patch
RUN cd /usr/src/nginx-*.*/ && dpkg-buildpackage -b -j
RUN sudo dpkg -i nginx-common_*.deb nginx-full_*.deb; apt-get install -y --force-yes -f
RUN mv /var/www/nginx /var/www/rtmp; mv /var/log/nginx /var/log/rtmp
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/crossdomain.xml /var/www/rtmp/crossdomain.xml
COPY nginx/index.html /var/www/rtmp/index.html
RUN chown -R www-data:www-data /var/lib/nginx

# Clean up
RUN rm -rf /usr/src/nginx* /var/lib/apt/lists/* && \

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
