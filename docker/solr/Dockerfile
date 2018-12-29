FROM solr:7.5

COPY ./configsets/sunspot /opt/solr/server/solr/configsets/sunspot
USER root
RUN chown -R solr:solr /opt/solr/server/solr/configsets/sunspot
USER solr
#CMD ["/opt/solr/bin/solr", "-f"]
