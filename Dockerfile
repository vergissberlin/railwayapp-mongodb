FROM mongo:7

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD mongosh --quiet --eval "db.adminCommand('ping')" || exit 1
