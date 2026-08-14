#!/bin/sh
set -e

# Optional: restore a mongorestore-compatible archive on the very first
# start of an empty data directory. Mongo's own docker-entrypoint-initdb.d
# only executes *.js (via mongosh) and *.sh files - it has no native
# support for raw dump/archive files the way mysql/postgres do for .sql.
# So instead of dropping the archive itself in initdb.d, this materializes
# it to disk and generates a tiny .sh script that runs `mongorestore`
# against it; mongo's upstream entrypoint then picks that script up and
# runs it during its first-init phase for us.
MONGO_DBPATH="/data/db"
MONGO_INITDB_DIR="/docker-entrypoint-initdb.d"
MONGO_DUMP_ARCHIVE="/tmp/mongo-init-dump.archive"
MONGO_RESTORE_SCRIPT="$MONGO_INITDB_DIR/00-restore-dump.sh"

# Mirrors the check mongo's own docker-entrypoint.sh uses internally to
# decide the data dir has already been bootstrapped: presence of any of
# these means this is not a fresh, empty volume.
mongo_already_initialized() {
  for f in "$MONGO_DBPATH/WiredTiger" "$MONGO_DBPATH/journal" "$MONGO_DBPATH/local.0" "$MONGO_DBPATH/storage.bson"; do
    [ -e "$f" ] && return 0
  done
  return 1
}

if ! mongo_already_initialized; then
  if [ -n "$MONGO_INIT_DUMP_URL" ] || [ -n "$MONGO_INIT_DUMP_BASE64" ]; then
    if [ -n "$MONGO_INIT_DUMP_URL" ]; then
      if [ -n "$MONGO_INIT_DUMP_BASE64" ]; then
        echo "[Entrypoint] Both MONGO_INIT_DUMP_URL and MONGO_INIT_DUMP_BASE64 are set; URL takes precedence, ignoring MONGO_INIT_DUMP_BASE64." >&2
      fi
      echo "[Entrypoint] MONGO_INIT_DUMP_URL set - fetching initial dump archive for first-time import..."
      if ! curl -fsSL -L --connect-timeout 10 --max-time 300 --retry 3 --retry-delay 2 \
             -o "$MONGO_DUMP_ARCHIVE" "$MONGO_INIT_DUMP_URL"; then
        echo "[Entrypoint] ERROR: failed to download dump from MONGO_INIT_DUMP_URL. Aborting startup rather than silently booting an empty database." >&2
        exit 1
      fi
    else
      echo "[Entrypoint] MONGO_INIT_DUMP_BASE64 set - decoding initial dump archive for first-time import..."
      if ! printf '%s' "$MONGO_INIT_DUMP_BASE64" | base64 -d > "$MONGO_DUMP_ARCHIVE" 2>/tmp/mongo-b64-err.log; then
        echo "[Entrypoint] ERROR: failed to base64-decode MONGO_INIT_DUMP_BASE64 (invalid base64?). Aborting startup rather than silently booting an empty database." >&2
        cat /tmp/mongo-b64-err.log >&2 || true
        exit 1
      fi
    fi

    if [ ! -s "$MONGO_DUMP_ARCHIVE" ]; then
      echo "[Entrypoint] ERROR: resolved init dump is empty. Aborting startup rather than silently booting an empty database." >&2
      exit 1
    fi

    gzip_flag=""
    if gzip -t "$MONGO_DUMP_ARCHIVE" 2>/dev/null; then
      gzip_flag=" --gzip"
      echo "[Entrypoint] Detected gzip-compressed archive; mongorestore will be run with --gzip."
    fi

    mkdir -p "$MONGO_INITDB_DIR"
    cat > "$MONGO_RESTORE_SCRIPT" <<-EOF
	#!/bin/sh
	set -e
	echo "[Entrypoint] Restoring initial dump via mongorestore --archive=$MONGO_DUMP_ARCHIVE$gzip_flag --drop"
	mongorestore --quiet --drop$gzip_flag --archive="$MONGO_DUMP_ARCHIVE"
	EOF
    chmod +x "$MONGO_RESTORE_SCRIPT"
    echo "[Entrypoint] Generated $MONGO_RESTORE_SCRIPT for first-time import (mongo's native docker-entrypoint.sh will execute it)."
  fi
fi

exec docker-entrypoint.sh "$@"
