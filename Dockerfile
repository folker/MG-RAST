# MG-RAST API

FROM httpd:2.4

# MG-RAST dependencies
RUN apt-get update && apt-get install -y \
  apache2 \
  libpq-dev \
  make \
  cdbfasta 	\
  curl \
  perl-modules \
  liburi-perl \
  libwww-perl \
  libjson-perl \
  libdbi-perl \
  libdbd-mysql-perl \
  libdbd-pg-perl \
  libdigest-md5-perl \
  libfile-slurp-perl \
  libhtml-strip-perl \
  liblist-moreutils-perl \
  libcache-memcached-perl \
  libhtml-template-perl \
  libdigest-md5-perl \
  libdigest-md5-file-perl \
  libdatetime-perl \
  libdatetime-format-ISO8601-perl \
  liblist-allutils-perl \
  libposix-strptime-perl \
  libuuid-tiny-perl \
  libmongodb-perl \
  libfreezethaw-perl \
  libtemplate-perl \
  libclass-isa-perl \
#  python-cassandra-driver \
  python-dev \
  python-lepl \
  python-openpyxl \
  python-pip \
  python-xlrd \
  r-base \
  r-bioc-biobase \
  r-bioc-deseq2 \
  r-cran-ecodist \
  r-cran-nlme \
  r-bioc-preprocesscore \
  r-cran-rcolorbrewer \
  r-cran-xml \
  && rm -rf /usr/share/doc/ /usr/share/man/ /usr/share/X11/ /usr/share/i18n/ /usr/share/mime /usr/share/locale

RUN mkdir -p /MG-RAST /var/log/httpd/api.metagenomics
COPY . /MG-RAST
RUN cd /MG-RAST && \
  make && \
#  make api-doc && \
  cp -rv src/MGRAST/bin/* bin/. && \
  cd site/CGI 

# R dependencies
#RUN echo 'install.packages("matlab", repos = "http://cran.wustl.edu")' | R --no-save && \
  echo 'source("http://bioconductor.org/biocLite.R"); biocLite("pcaMethods"); biocLite("DESeq")' | R --no-save


#####
##### we have moved the AWE templates to the API server repo from the pipeline 
RUN    pip install gspread &&  \
	   ln -s /MG-RAST/site/CGI/Tmp temp

ENV PERL_MM_USE_DEFAULT 1
RUN cpan Inline::Python

# setup sendmail
RUN echo " NEED TO MAKE SURE TRAVIS HAS changed "
#RUN  cp /usr/share/postfix/main.cf.debian /etc/postfix/main.cf && \
#  postconf -e relayhost=[smtp.mcs.anl.gov] && \
#  postconf -e myorigin=mcs.anl.gov
# find correct EXIM config to forward to SMTP smarthost

# add to /etc/exim/exim.conf :
# ----snip---
# send_to_smart_host:
#  driver = manualroute
#  route_list = !+local_domains smtp.mcs.anl.gov
#  transport = remote_smtp
# ----snip---

RUN mkdir -p /sites/1/ &&   \
	cd /sites/1/ &&   \
	ln -s /MG-RAST/

# Configuration in mounted directory
RUN cd /MG-RAST/conf && ln -s /api-server-conf/Conf.pm && \
	mkdir -p /pipeline/conf && \
	cd /pipeline/conf && \
  	ln -s /api-server-conf/PipelineAWE_Conf.pm

# certificates need to be in daemon home directory
RUN ln -s /api-server-conf/postgresql/ /usr/sbin/.postgresql

# m5nr blast files in mounted dir
RUN mkdir -p /m5nr && \
  ln -s /api-server-data/20100309 /m5nr/20100309 && \
  ln -s /api-server-data/20131215 /m5nr/20131215

# Execute:
# /etc/init.d/	 start
# /usr/local/apache2/bin/httpd -DFOREGROUND -f /api-server-conf/httpd.conf
