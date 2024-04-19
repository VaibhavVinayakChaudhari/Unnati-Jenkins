FROM docker.io/httpd
RUN echo " development" > /usr/local/apache2/htdocs/index.html
