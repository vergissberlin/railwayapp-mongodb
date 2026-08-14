FROM mongo:7

# curl + gzip for the optional first-init dump import (MONGO_INIT_DUMP_URL) -
# mongo:7 is ubuntu:jammy based and ships neither by default. gzip is used
# only for our own compression detection (mongorestore --gzip handles the
# actual decompression). mongodb-database-tools provides `mongorestore`,
# which isn't bundled in the base image (only mongod/mongosh are) - the
# upstream image already configures the MongoDB apt repo to install mongod
# itself, so this reuses that same repo rather than adding a new one.
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl gzip mongodb-database-tools \
 && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD mongosh --quiet --eval "db.adminCommand('ping')" || exit 1

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["mongod"]
