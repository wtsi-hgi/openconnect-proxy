FROM ubuntu:16.04
MAINTAINER "Joshua C. Randall" <jcrandall@alum.mit.edu>

# Update and install packages
RUN apt-get -qqy update && \
    apt-get -qqy install \
      openconnect \
      ocproxy \
      polipo

# Setup openconnect proxy entrypoint
ADD openconnect-proxy.sh /docker/openconnect-proxy.sh
ENTRYPOINT ["/docker/openconnect-proxy.sh"]

# Expose port 8123 for the polipo authenticating http proxy 
EXPOSE 8123
