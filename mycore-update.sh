docker-compose stop
docker-compose rm --force
docker images mycore/mir --quiet| xargs docker image rm --force
rm -rf ./solr ./pg ./mir && \
#docker build . --build-arg MIR_VERSION="2019.06.5-SNAPSHOT" -t mycore/mir:2019.06.5&& \
docker build . --build-arg MIR_VERSION="2021.06.1-SNAPSHOT" -t mycore/mir:2021.06.1 && \
docker build . --build-arg MIR_VERSION="2021.11-SNAPSHOT" -t mycore/mir:master && \
#mkdir -p ./solr/2019 && chown 8983:8983 ./solr/2019 && \
mkdir -p ./solr/2021 && chown 8983:8983 ./solr/2021 && \
mkdir -p ./solr/master && chown 8983:8983 ./solr/master && \
docker-compose up --no-start && \
docker-compose start

