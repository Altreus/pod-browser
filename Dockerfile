FROM perl:5.30.0

VOLUME /opt/libs
WORKDIR /opt
COPY browser.pl .
COPY cpanfile .
COPY pod-browser.conf.docker ./pod-browser.conf

RUN cpanm --installdeps .

ENTRYPOINT ["perl", "browser.pl", "daemon"]
