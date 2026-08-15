# MongoDB for railway.app

![Template Header](./template-header.svg)

Deploy MongoDB 7 on Railway with the official Docker image.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/mongodb-vb?referralCode=2_sIT9&utm_medium=integration&utm_source=template&utm_campaign=generic)

## 🏗️ Architecture

```mermaid
flowchart LR
    Client(["📦 App / Client"]) -->|"MongoDB Wire Protocol"| Proxy["Railway TCP Proxy"]
    Proxy -->|"$PORT → 27017"| App["Container\nmongo:7"]
    App --> Volume[("Volume\n/data/db")]
```

## Environment

| Variable | Required | Description |
|----------|----------|-------------|
| `MONGO_INITDB_ROOT_USERNAME` | Yes | Root username created on first start of an empty volume. Set this in the Railway dashboard as a generated secret. |
| `MONGO_INITDB_ROOT_PASSWORD` | Yes | Root password created on first start of an empty volume. Set this in the Railway dashboard as a generated secret. |

Both variables must be set together before the first deployment — MongoDB only
enables authentication and creates the root user on an empty data directory.
Deploying without them leaves the database unauthenticated and reachable by
anyone with network access to it. See [`.env.example`](./.env.example) for local development.

## Optional

| Variable | Description |
|----------|-------------|
| `MONGO_INIT_DUMP_URL` | HTTPS URL to a `mongorestore`-compatible single-file archive (`mongodump --archive[--gzip]` output, **not** a `mongodump --out` directory tree); downloaded and restored via `mongorestore --archive --drop` automatically, but only on the first start of an empty volume. Takes precedence over `MONGO_INIT_DUMP_BASE64` if both are set. |
| `MONGO_INIT_DUMP_BASE64` | Same archive, base64-encoded and pasted directly as the variable value. Ignored if `MONGO_INIT_DUMP_URL` is also set. Best for small dumps only. |

> [!NOTE]
> `MONGO_INIT_DUMP_URL`/`MONGO_INIT_DUMP_BASE64` are only ever consulted on the very first start against a brand-new, empty volume. Once the database has initialized, both variables are silently ignored on every later restart or redeploy — even if you leave them set. The restore runs with full administrative privileges during bootstrap, so only point these at dumps from sources you trust.

## Health Check

The image defines a `HEALTHCHECK` that runs `mongosh --eval "db.adminCommand('ping')"`
every 30 seconds so container orchestrators (including Railway) can detect an
unhealthy instance.

## Persistence

`railway.toml` declares `requiredMountPath = "/data/db"`. Attach a Railway volume to that path before production traffic — Railway will prompt for it based on this setting, but it is not created automatically.

## Local

```bash
cp .env.example .env
docker build -t railwayapp-mongodb .
docker run --rm -p 27017:27017 --env-file .env railwayapp-mongodb
```

<!-- footer -->
---

[![Airbyte](https://img.shields.io/badge/Airbyte-615EFF?style=for-the-badge&logo=airbyte&logoColor=white)](https://github.com/vergissberlin/railwayapp-airbyte) [![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=apacheairflow&logoColor=white)](https://github.com/vergissberlin/railwayapp-airflow) [![CloudBeaver](https://img.shields.io/badge/CloudBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://github.com/vergissberlin/railwayapp-cloudbeaver-ce) [![CodiMD](https://img.shields.io/badge/CodiMD-0F766E?style=for-the-badge&logo=markdown&logoColor=white)](https://github.com/vergissberlin/railwayapp-codimd) [![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)](https://github.com/vergissberlin/railwayapp-django) [![Email Service](https://img.shields.io/badge/Email%20Service-2563EB?style=for-the-badge&logo=maildotru&logoColor=white)](https://github.com/vergissberlin/railwayapp-email) [![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://github.com/vergissberlin/railwayapp-fastapi) [![Flask](https://img.shields.io/badge/Flask-3fad48?style=for-the-badge&logo=flask&logoColor=white)](https://github.com/vergissberlin/railwayapp-flask) [![Flowise](https://img.shields.io/badge/Flowise-4F46E5?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://github.com/vergissberlin/railwayapp-flowise) [![GitLab CE](https://img.shields.io/badge/GitLab%20CE-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white)](https://github.com/vergissberlin/railwayapp-gitlab) [![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://github.com/vergissberlin/railwayapp-grafana) [![Home Assistant](https://img.shields.io/badge/Home%20Assistant-18BCF2?style=for-the-badge&logo=homeassistant&logoColor=white)](https://github.com/vergissberlin/railwayapp-homeassistant) [![InfluxDB](https://img.shields.io/badge/InfluxDB-22ADF6?style=for-the-badge&logo=influxdb&logoColor=white)](https://github.com/vergissberlin/railwayapp-influxdb) [![MJML](https://img.shields.io/badge/MJML-F45E43?style=for-the-badge&logo=mjml&logoColor=white)](https://github.com/vergissberlin/railwayapp-mjml) [![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://github.com/vergissberlin/railwayapp-mongodb) [![Mosquitto MQTT](https://img.shields.io/badge/Mosquitto%20MQTT-3C5280?style=for-the-badge&logo=eclipsemosquitto&logoColor=white)](https://github.com/vergissberlin/railwayapp-mqtt) [![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://github.com/vergissberlin/railwayapp-mysql) [![n8n](https://img.shields.io/badge/n8n-EA4B71?style=for-the-badge&logo=n8n&logoColor=white)](https://github.com/vergissberlin/railwayapp-n8n) [![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://github.com/vergissberlin/railwayapp-nodejs) [![Node-RED](https://img.shields.io/badge/Node-RED-8F0000?style=for-the-badge&logo=nodered&logoColor=white)](https://github.com/vergissberlin/railwayapp-nodered) [![OpenSearch](https://img.shields.io/badge/OpenSearch-005EB8?style=for-the-badge&logo=opensearch&logoColor=white)](https://github.com/vergissberlin/railwayapp-opensearch) [![Outerbase Studio](https://img.shields.io/badge/Outerbase%20Studio-000000?style=for-the-badge&logo=outerbase&logoColor=white)](https://github.com/vergissberlin/railwayapp-outerbase-studio) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://github.com/vergissberlin/railwayapp-postgresql) [![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://github.com/vergissberlin/railwayapp-redis) [![TYPO3 CMS](https://img.shields.io/badge/TYPO3%20CMS-FF8700?style=for-the-badge&logo=typo3&logoColor=white)](https://github.com/vergissberlin/railwayapp-typo3)
