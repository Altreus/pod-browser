FROM perl:5.30.0

VOLUME /opt/libs
WORKDIR /opt
COPY cpanfile .
RUN cpanm --installdeps .

COPY browser.pl .
COPY pod-browser.conf.docker ./pod-browser.conf


ENTRYPOINT ["perl", "browser.pl", "daemon"]
