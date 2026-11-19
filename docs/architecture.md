# Architecture

The module is rootless and runs one instance per node. Traefik is the entry point from
outside. It reaches every service on 127.0.0.1.

## Network

| Service | Network | Listens on |
|---|---|---|
| Synapse | host | `127.0.0.1:SYNAPSE_PORT` (`bind_addresses` in `homeserver.yaml`) |
| PostgreSQL | rootless bridge | `127.0.0.1:POSTGRES_PORT`, published to 5432 in the container |
| Element web | rootless bridge | `127.0.0.1:ELEMENT_WEB_PORT`, published to 8080 in the container |
| Cinny | rootless bridge | `127.0.0.1:CINNY_PORT`, published to 80 in the container |
| matrix2acrobits | host | every interface, `M2A_PROXY_PORT` |

matrix2acrobits only reads a port, not a listen address, so it listens on every interface. It
runs only when `nethvoice_auth_url` is set. The node firewall keeps its port closed from
outside. The Element image runs as a non-root user and cannot bind port 80, so it listens on
8080 inside the container.

## Ports

NS8 allocates 5 TCP ports (`org.nethserver.tcp-ports-demand=5`). `configure-module` assigns
them in this order:

| Index | Variable | Service |
|---|---|---|
| 0 | `SYNAPSE_PORT` | Synapse |
| 1 | `ELEMENT_WEB_PORT` | Element web |
| 2 | `CINNY_PORT` | Cinny |
| 3 | `POSTGRES_PORT` | PostgreSQL |
| 4 | `M2A_PROXY_PORT` | matrix2acrobits |

## Traefik routes

```mermaid
flowchart LR
    T["Traefik :443"]
    T -- "host synapse_domain_name<br/>route matrix1-synapse" --> S["Synapse<br/>SYNAPSE_PORT"]
    T -- "host element_domain_name<br/>route matrix1-element" --> E["Element<br/>ELEMENT_WEB_PORT"]
    T -- "host cinny_domain_name<br/>route matrix1-cinny" --> C["Cinny<br/>CINNY_PORT"]
    T -- "synapse_domain_name/m2a<br/>route matrix1-m2a, prefix stripped" --> M["matrix2acrobits<br/>M2A_PROXY_PORT"]
    T -- "synapse_domain_name/_matrix/push/v1/notify<br/>route matrix1-push" --> M
```

The Synapse route always exists. The Element and Cinny routes exist when their domain name is
set. The two matrix2acrobits routes exist when `nethvoice_auth_url` is set. Otherwise
`configure-module` deletes them. All routes redirect HTTP to HTTPS and follow `lets_encrypt`.

With federation, Synapse adds the `federation` listener resource and serves
`/.well-known/matrix/server` on the same route.

## Systemd units

```mermaid
flowchart TB
    PG[postgresql.service]
    SY[synapse.service]
    EW[element-web.service]
    CI[cinny.service]
    MA[matrix2acrobits.service]
    PG -- "Before" --> SY
    EW -- "After, Wants" --> SY
    CI -- "After, Wants" --> SY
    MA -- "After, Wants" --> SY
```

`postgresql.service` has `Before=synapse.service`. This is ordering only, there is no `Wants`
or `Requires`. When both start in the same transaction, at boot or in `80start_services`,
systemd waits for PostgreSQL to be started before it starts Synapse. PostgreSQL counts as
started only when its `ExecStartPost` loop can open the `synapse` database, so Synapse finds
the database ready.

`80start_services` enables `postgresql` and `synapse` always. It enables `element-web` and
`cinny` when their domain name is set, and `matrix2acrobits` when `nethvoice_auth_url` is set.
The others are disabled and stopped.

Each unit runs scripts as `ExecStartPre`:

| Unit | Scripts |
|---|---|
| `synapse.service` | `discover-ldap`, `discover-smarthost`, `configure-matrix`, then `synapse generate` |
| `postgresql.service`, `element-web.service`, `cinny.service`, `matrix2acrobits.service` | `configure-matrix` |

## Configuration rendering

```mermaid
flowchart LR
    R[configure-module request] --> CE[state/config.env]
    R --> CJ[state/config.json]
    R --> TE[state/turn.env]
    DL[discover-ldap] --> LE[state/ldap.env]
    R --> ME[state/m2a.env]
    DS[discover-smarthost] --> SE[state/smarthost.env]
    CM[configure-matrix]
    CE --> CM
    LE --> CM
    SE --> CM
    TE --> CM
    DB[state/database.env] --> CM
    MS[state/matrix-secrets.env] --> CM
    CM --> H[synapse-config/homeserver.yaml]
    CM --> LC[synapse-config/log.config]
    CM --> A[synapse-config/matrix2acrobits.yaml]
    CM --> EC[element-config/config.json]
    CM --> CC[cinny-config/config.json]
```

`20configure` validates the request, writes `config.env`, `config.json` and `turn.env`, sets
the Traefik routes and writes `m2a.env` for matrix2acrobits. It does not render the service
configuration.

`configure-matrix` renders the files in `templates/` with the values of the env files. It
creates `database.env` and `matrix-secrets.env` when they are missing. It runs before every
service start, so the rendered files always match the templates of the current image. Manual
changes to them are lost.

## Module state

| File or volume | Written by | In the backup |
|---|---|---|
| `config.env` | `configure-module` | no, rebuilt from `config.json` |
| `config.json` | `configure-module` | yes |
| `turn.env` | `configure-module` | yes |
| `m2a.env` | `configure-module` | no, rebuilt from `config.json` |
| `database.env` | `configure-matrix` | yes |
| `matrix-secrets.env` | `configure-matrix` | no, regenerated |
| `ldap.env` | `discover-ldap` | no, rediscovered |
| `smarthost.env` | `discover-smarthost` | no, rediscovered |
| rendered configs | `configure-matrix` | no, rendered again |
| `postgresql.pg_dump` | `module-dump-state` | yes |
| `postgres-data` volume | PostgreSQL | no, the dump is used |
| `synapse-data` volume | Synapse | yes |
| `matrix2acrobits-data` volume | matrix2acrobits | yes |

The list of backed up paths is in `etc/state-include.conf`.

## Events

| Event | Handler |
|---|---|
| `ldap-changed` | restarts `synapse.service` |
| `smarthost-changed` | restarts `synapse.service`, the unit has no reload command |

## PostgreSQL migration

`update-module.d/05database_upgrade` runs before the services restart on update.

```mermaid
flowchart TB
    A{"upgrade.pg_dump exists?"}
    A -- yes --> R["resume: stop services"]
    A -- no --> B["read PG_VERSION from the postgres-data volume"]
    B --> C{"same major as POSTGRES_IMAGE?"}
    C -- yes --> X[skip]
    C -- no --> D["pull the old image<br/>abort if unknown or pull fails"]
    D --> E["stop synapse, matrix2acrobits, postgresql"]
    E --> F["start the old PostgreSQL on the volume<br/>pg_dumpall to upgrade.pg_dump<br/>save row counts"]
    F --> G
    R --> G["remove the postgres-data volume"]
    G --> H["restore the dump with the new image"]
    H --> I{"row counts match?"}
    I -- no --> K["fail, keep upgrade.pg_dump"]
    I -- yes --> J["delete the dump, start enabled services"]
```

The old images are listed in `old_images`. When bumping the PostgreSQL major version, add the
image the module shipped before the bump. Up to PostgreSQL 17 the data sits at the volume root,
from 18 under `<major>/docker`. The script reads `PG_VERSION` from the host side, because
mounting the volume with `:Z` in a helper container would lock out a running PostgreSQL.
