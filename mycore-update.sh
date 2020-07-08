docker-compose stop
docker-compose rm --force
docker images mycore/mir --quiet| xargs docker image rm --force
rm -rf ./solr ./pg ./mir && \
docker build . --build-arg MIR_VERSION="2019.06.5-SNAPSHOT" -t mycore/mir:2019.06.5&& \
docker build . --build-arg MIR_VERSION="2020.06.0-SNAPSHOT" -t mycore/mir:2020.06.0 && \
docker build . --build-arg MIR_VERSION="2020.08-SNAPSHOT" -t mycore/mir:master && \
mkdir -p ./solr/2019 && chown 8983:8983 ./solr/2019 && \
mkdir -p ./solr/2020 && chown 8983:8983 ./solr/2020 && \
mkdir -p ./solr/master && chown 8983:8983 ./solr/master && \
docker-compose create && \
docker-compose start

