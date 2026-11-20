# Architecture

The module is rootless and runs one instance per node. Traefik is the entry point from
outside. It reaches every service on 127.0.0.1.

## Network

Every container runs in one rootless pod named `matrix`, created by `matrix.service`. The
containers reach each other on the pod loopback. LiveKit is the only exception, see below.
The pod publishes these ports on 127.0.0.1 of the node:

| Service | Listens in the pod | Published on the node |
|---|---|---|
| Synapse | `SYNAPSE_PORT` (`bind_addresses` in `homeserver.yaml`) | `127.0.0.1:SYNAPSE_PORT` |
| PostgreSQL | `5432` | not published |
| Element web | `8080` | `127.0.0.1:ELEMENT_WEB_PORT` |
| Cinny | `80` | `127.0.0.1:CINNY_PORT` |
| matrix2acrobits | `M2A_PROXY_PORT` | `127.0.0.1:M2A_PROXY_PORT` |
| lk-jwt-service | `LK_JWT_PORT` | `127.0.0.1:LK_JWT_PORT` |

The pod uses pasta with its own address, `10.0.2.100`. It keeps reaching the node IP, so a
NethVoice or a smarthost on the same node still answers. `--map-gw` makes the gateway
`10.0.2.2` lead to the node loopback. `discover-ldap` and `discover-smarthost` write `10.0.2.2`
when the user domain or the smarthost resolves to a loopback address on the node.

The pod publishes the Element, Cinny and matrix2acrobits ports even when these services are
off, because publishing is fixed when the pod is created. The Element image runs as a
non-root user and cannot bind port 80, so it listens on 8080 inside the pod.

Legacy one to one calls never go through the module. Clients talk WebRTC to each other or
through the external TURN server.

LiveKit runs outside the pod, in the node network namespace, like the BigBlueButton media
server. Call media must leave from the node address, and pasta would rewrite it. Its HTTP port
listens on 127.0.0.1 only. Its media ports 7881/tcp and 7882/udp, and 3478/udp with TURN, are
opened in the firewall through `add_public_service`, only while `livekit_enabled` is true.

## Ports

NS8 allocates 6 TCP ports (`org.nethserver.tcp-ports-demand=6`). `configure-module` assigns
them in this order:

| Index | Variable | Service |
|---|---|---|
| 0 | `SYNAPSE_PORT` | Synapse |
| 1 | `ELEMENT_WEB_PORT` | Element web |
| 2 | `CINNY_PORT` | Cinny |
| 3 | `LIVEKIT_HTTP_PORT` | LiveKit signaling and API, 127.0.0.1. Was `POSTGRES_PORT` before the pod |
| 4 | `M2A_PROXY_PORT` | matrix2acrobits |
| 5 | `LK_JWT_PORT` | lk-jwt-service |

An instance installed before LiveKit has 5 TCP ports. The core does not allocate new ports on
update, so `bin/apply-livekit-ports` allocates the missing one once and stores it in the
module environment.

The LiveKit media ports are fixed, outside the NS8 allocator: 7881/tcp, 7882/udp, and
3478/udp with TURN. The router forward then survives a restore, a clone or a move to another
node. `bin/port-owner` refuses to enable LiveKit or its TURN when another application holds
one of them.

## Traefik routes

```mermaid
flowchart LR
    T["Traefik :443"]
    T -- "host synapse_domain_name<br/>route matrix1-synapse" --> S["Synapse<br/>SYNAPSE_PORT"]
    T -- "host element_domain_name<br/>route matrix1-element" --> E["Element<br/>ELEMENT_WEB_PORT"]
    T -- "host cinny_domain_name<br/>route matrix1-cinny" --> C["Cinny<br/>CINNY_PORT"]
    T -- "synapse_domain_name/m2a<br/>route matrix1-m2a, prefix stripped" --> M["matrix2acrobits<br/>M2A_PROXY_PORT"]
    T -- "synapse_domain_name/_matrix/push/v1/notify<br/>route matrix1-push" --> M
    T -- "synapse_domain_name/livekit/sfu<br/>route matrix1-livekit-sfu, prefix stripped" --> L["LiveKit<br/>LIVEKIT_HTTP_PORT"]
    T -- "synapse_domain_name/livekit/jwt<br/>route matrix1-livekit-jwt, prefix stripped" --> J["lk-jwt-service<br/>LK_JWT_PORT"]
```

The Synapse route always exists. The Element and Cinny routes exist when their domain name is
set. The two matrix2acrobits routes exist when `nethvoice_auth_url` is set. The two LiveKit
routes exist when `livekit_enabled` is true. Otherwise
`configure-module` deletes them. All routes redirect HTTP to HTTPS and follow `lets_encrypt`.

With federation, Synapse adds the `federation` listener resource and serves
`/.well-known/matrix/server` on the same route. With LiveKit and no federation, it adds the
`openid` resource instead and still serves the server well-known: lk-jwt-service finds the
OpenID userinfo endpoint through it. Synapse also appends `templates/synapse-livekit.yaml`:
`matrix_rtc` transports, `msc4143_enabled`, the `rtc_foci` client well-known for Cinny,
delayed events and the rate limits Element Call needs.

## Systemd units

```mermaid
flowchart TB
    MX[matrix.service<br/>pod]
    PG[postgresql.service]
    SY[synapse.service]
    EW[element-web.service]
    CI[cinny.service]
    MA[matrix2acrobits.service]
    LJ[lk-jwt.service]
    LK[livekit.service<br/>host network]
    PG -- "BindsTo, After" --> MX
    SY -- "BindsTo, After" --> MX
    EW -- "BindsTo, After" --> MX
    CI -- "BindsTo, After" --> MX
    MA -- "BindsTo, After" --> MX
    LJ -- "BindsTo, After" --> MX
    SY -- "Before" --> LK
    PG -- "Before" --> SY
```

`matrix.service` creates the pod. Every container unit has `BindsTo=matrix.service` and
`After=matrix.service`: starting a container starts the pod first, and stopping the pod stops
every container. Once the pod runs, its `ExecStartPost` starts each enabled container without
waiting, so the containers come back after a pod crash. The pod has no `Requires=` on the
containers, so restarting Synapse alone, for example on `ldap-changed`, leaves the pod and the
other containers running.

`livekit.service` is not in the pod and is not bound to it, so a pod restart leaves it
running. `80start_services` and `update-module.d/80restart_services` restart it, and
`lk-jwt.service`, so they always load the new configuration.

`80start_services` stops the disabled clients, restarts the pod, then starts PostgreSQL,
Synapse and the enabled clients. `update-module.d/80restart_services` does the same when
`synapse.service` is enabled, and does nothing otherwise.

PostgreSQL counts as started only when its `ExecStartPost` loop can open the `synapse`
database, so Synapse finds the database ready.

`80start_services` enables `matrix`, `postgresql` and `synapse` always. It enables
`element-web` and `cinny` when their domain name is set, and `matrix2acrobits` when
`nethvoice_auth_url` is set. The others are disabled and stopped.

The first update to the pod runs `update-module.d/06stop_before_pod`, after the PostgreSQL
upgrade. It stops the old containers, which hold the ports the pod publishes, and the old
oneshot `matrix.service`.

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
    D --> E["stop every container and the pod"]
    E --> F["start the old PostgreSQL on the volume<br/>pg_dumpall to upgrade.pg_dump<br/>save row counts"]
    F --> G
    R --> G["remove the postgres-data volume"]
    G --> H["restore the dump with the new image"]
    H --> I{"row counts match?<br/>read in a throwaway container"}
    I -- no --> K["fail, keep upgrade.pg_dump"]
    I -- yes --> J["delete the dump, start PostgreSQL,<br/>then Synapse and matrix2acrobits if enabled"]
```

The row counts are read in a throwaway PostgreSQL container: starting `postgresql.service`
would start the pod, which starts Synapse on a database not yet checked.

The old images are listed in `old_images`. When bumping the PostgreSQL major version, add the
image the module shipped before the bump. Up to PostgreSQL 17 the data sits at the volume root,
from 18 under `<major>/docker`. The script reads `PG_VERSION` from the host side, because
mounting the volume with `:Z` in a helper container would lock out a running PostgreSQL.
