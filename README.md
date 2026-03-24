# MongoDB for railway.app

![Template Header](./template-header.svg)

Deploy MongoDB 7 on Railway with the official Docker image.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template)

## Environment

| Variable | Required | Description |
|----------|----------|-------------|
| None | — | Optional auth via `MONGO_INITDB_ROOT_USERNAME` / `MONGO_INITDB_ROOT_PASSWORD` |

## Persistence

Mount a Railway volume at `/data/db` for durable storage.

## Local

```bash
docker build -t railwayapp-mongodb .
docker run --rm -p 27017:27017 railwayapp-mongodb
```
