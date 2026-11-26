# Admin guide

This guide assumes an instance named `matrix1`.

## UI pages

- **Status**: running services, installation node, backups and the module logs.
- **Settings**: every parameter below. Turning the TURN switch off sends `turn_clear_secret`.
- **About**: module information.

## Parameters

Set them in the Settings page or with `configure-module`.

| Parameter | Default | Description |
|---|---|---|
| `synapse_domain_name` | required | FQDN of the Matrix server, for example `matrix.example.com`. Clients connect to it. It can change later. |
| `matrix_server_name` | see below | User domain, for example `example.com`. User IDs look like `@user:example.com`. It cannot change once a user has logged in, see [User domain](#user-domain). |
| `lets_encrypt` | required | Request Let's Encrypt certificates for all the configured domains. A failed challenge refuses the request. |
| `ldap_domain` | required | LDAP domain used for authentication. |
| `element_domain_name` | empty | FQDN of the Element web client. Empty disables Element. |
| `cinny_domain_name` | empty | FQDN of the Cinny web client. Empty disables Cinny. |
| `mail_from` | empty | Sender address of notification mails, see [Mail](#mail). |
| `nethvoice_auth_url` | empty | NethVoice authentication URL. When set, matrix2acrobits runs, see [NethVoice integration](nethvoice.md). |
| `federation` | `false` | Let users talk with other Matrix servers, see [Federation](#federation). |
| `federation_whitelist` | `[]` | Server names allowed to federate. Empty means any server. |
| `turn_uris` | `[]` | External TURN server URIs, see [Voice and video calls](#voice-and-video-calls). |
| `turn_shared_secret` | empty | TURN shared secret. Empty keeps the stored secret. |
| `turn_clear_secret` | `false` | Delete the stored TURN secret. |
| `livekit_enabled` | `false` | Run LiveKit for Element Call, see [Element Call with LiveKit](#element-call-with-livekit). |
| `livekit_turn_enabled` | `false` | Start the LiveKit TURN relay on 3478/udp. Needs `livekit_enabled`. |
| `livekit_public_address` | empty | Address announced to call clients. Empty uses the detected public address. |
| `livekit_tls_skip_verify` | `false` | Test labs only, not in the UI. lk-jwt-service accepts a self signed certificate. |
| `max_upload_size_mb` | `50` | Largest file a user can upload, in megabytes. |
| `local_media_lifetime_days` | `0` | Delete uploaded files not viewed for this many days. `0` keeps them forever. |
| `remote_media_lifetime_days` | `0` | Delete cached files from other servers not viewed for this many days. `0` keeps them forever. |
| `search_all_users` | see below | Let users find every user of the LDAP domain, not only people they share a room with. |
| `encryption_enabled` | `true` | Let users create end-to-end encrypted rooms, see [Encryption](#encryption). Missing keeps the stored value. |
| `log_level` | `INFO` | `INFO`, `WARNING` or `DEBUG`. |

### A missing key resets to the default

`configure-module` does not merge the request with the stored configuration. A key missing
from the request takes the default of the table above. For example, a request without
`federation` disables federation, and a request without `turn_uris` clears TURN. The UI always
sends the full configuration, so this only matters with `api-cli`. Start from the output of
`get-configuration` and change what you need:

```sh
api-cli run module/matrix1/get-configuration
```

These keys behave differently:

- `turn_shared_secret`: missing or empty keeps the stored secret.
- `search_all_users`: missing keeps the stored value. An instance without a stored value gets
  `false`. The UI shows `true` for a new instance, so a module configured from the UI gets
  `true`. Only users who logged in at least once can be found, Synapse does not search the
  LDAP directory itself.
- `encryption_enabled`: missing keeps the stored value. An instance without a stored value gets
  `true`.
- `livekit_enabled`, `livekit_turn_enabled`, `livekit_tls_skip_verify` and
  `livekit_public_address`: missing keeps the stored value. An instance without a stored value
  gets the default.
- `matrix_server_name`: missing keeps the stored value, see [User domain](#user-domain).

### Validation errors

`turn_shared_secret_required`: `turn_uris` is set but no secret would remain. Either there is
no secret in the request and none stored, or the request has `turn_clear_secret: true` without
a new secret. The module is left untouched.

`turn_needs_livekit`: the request has `livekit_turn_enabled: true` with `livekit_enabled` off.

`livekit_port_in_use`: LiveKit is switched on, but another application holds 7881/tcp or
7882/udp on the node.

`turn_port_in_use`: the TURN relay is switched on, but another application holds 3478/udp.

`turn_no_relay_ports`: the TURN relay is switched on, but no UDP port range could be allocated
for it.

The port checks run only when the setting is switched on. The task log names the application
that holds the port.

`matrix_server_name_locked`: see [User domain](#user-domain).

## Web clients

A client is enabled when its domain name is set. An empty domain name stops it and removes its
Traefik route.

### Element

Element ships with custom themes, defined in the image template
`templates/element-config.json`. The module regenerates `state/element-config/config.json`
from this template at every service start and every `configure-module` run, so manual changes
to that file are lost.

### Cinny

Cinny is a lightweight alternative client. It is preconfigured for the local Synapse.
Its calls need [Element Call with LiveKit](#element-call-with-livekit).

## LDAP

Synapse authenticates users through the NS8 LDAP proxy, against the domain set in
`ldap_domain`. The module binds itself to that domain.

`bin/discover-ldap` runs when `synapse.service` starts and writes `state/ldap.env`. When the
LDAP settings of the cluster change, the `ldap-changed` event restarts Synapse. Any LDAP change
in the cluster triggers it, not only changes to the domain used by Matrix.

Users log in with their account name: `uid` with OpenLDAP, `sAMAccountName` with Active
Directory. Synapse turns it into the lowercase Matrix user ID. The display name comes from
`displayName`. Synapse sets it only at the first login, so existing users keep their current
name.

## User domain

`matrix_server_name` is the Synapse `server_name`: the part after the colon in `@user:example.com`.
It is written in every user ID, room ID and signed event, so Matrix cannot rename it. Synapse
refuses to start when it differs from the users already stored in the database. There is no
migration tool: a new user domain needs a new empty database.

So `configure-module` accepts a new `matrix_server_name` only while no user has logged in.
After that, it answers `validation-failed` with `matrix_server_name_locked`, and the Settings
page shows the field disabled. A request without `matrix_server_name` keeps the stored value.
Without a stored value, it takes `synapse_domain_name`.

`synapse_domain_name` stays free. It is only the address of the server.

The Synapse documentation recommends the bare domain as user domain, like an email address:
`@user:example.com` with the server at `matrix.example.com`. This is called delegation. The
Settings page suggests it: it fills the user domain with the Matrix server domain minus its
first label, until the field is edited.

### How clients and servers find the Matrix server

A client or server that knows only `@user:example.com` asks `https://example.com` where the
Matrix server is. Two files answer:

- `/.well-known/matrix/client`, for apps like Element X:

  ```json
  {"m.homeserver": {"base_url": "https://matrix.example.com"}}
  ```

- `/.well-known/matrix/server`, for other servers with federation, and for lk-jwt-service with
  Element Call:

  ```json
  {"m.server": "matrix.example.com:443"}
  ```

Replace `matrix.example.com` and `example.com` with your own domains. The web clients of the
module do not need these files: they connect to `synapse_domain_name` directly.

### DNS and web setup

`matrix.example.com` needs an A or AAAA record to the node, as before. So do the Element and
Cinny domains, when set. Nothing changes in the DNS for `example.com`. Like with email, it can
point to a website hosted elsewhere. What matters is where `https://example.com` answers.

If `example.com` points to a website elsewhere, publish the two files there:

- at `https://example.com/.well-known/matrix/client` and `/.well-known/matrix/server`
- with a valid certificate for `example.com`
- with `Content-Type: application/json`
- with `Access-Control-Allow-Origin: *` on the client file, so web clients can read it

If `example.com` points to this node, there is nothing to publish. When the two domains differ,
`configure-module` creates two Traefik routes on `example.com`: `/.well-known/matrix` and
`/_matrix` to Synapse. Synapse answers the server file with `example.com:443`, so the federation
traffic goes through the second route. Other paths of `example.com` stay free for another
application. These routes follow `lets_encrypt`. When `example.com` points elsewhere they are
never reached, and Let's Encrypt cannot validate them: Traefik logs the failure, the
configuration still succeeds. Each new configuration or Traefik restart retries the request.
After 5 failures in one hour, Let's Encrypt refuses `example.com` for an hour, and that also
delays a certificate for a website on `example.com` hosted on this node.

A DNS SRV record `_matrix-fed._tcp.example.com` can replace the server file, for federation
only. It is not recommended: other servers then expect a certificate for `example.com` on the
node. Clients have no DNS equivalent of the client file.

Check the result:

```
curl https://example.com/.well-known/matrix/client
curl https://example.com/.well-known/matrix/server
```

With federation, use the [Matrix Federation Tester](https://federationtester.matrix.org/) on
`example.com`.

### Existing installations

Before this setting existed, the user domain was `synapse_domain_name`. The update stores it as
`matrix_server_name`, so user IDs do not change. From then on, `synapse_domain_name` can change
like on a new installation.

## Federation

Federation is disabled by default: users can only talk with accounts of this server.

When `federation` is enabled, Synapse serves the federation API and answers
`/.well-known/matrix/server` with `<matrix_server_name>:443`. Other servers reach this one
through Traefik on port 443. Port 8448 is not needed.

Requirements:

- a public DNS record for `synapse_domain_name`
- a valid certificate for it, other servers refuse self-signed certificates
- when the user domain differs, the server file on the user domain, see
  [User domain](#user-domain)

Use `federation_whitelist` to federate only with known partners. Check the setup with the
[Matrix Federation Tester](https://federationtester.matrix.org/).

## Encryption

Matrix clients encrypt direct chats and private rooms by default. Each user then has to keep a
recovery key, or loses the history on a new device. With `encryption_enabled` set to `false`,
Synapse publishes this policy in `/.well-known/matrix/client`:

```json
{"io.element.e2ee": {"default": false, "force_disable": true}}
```

Element Web and the classic Element apps read it. They create new rooms and direct chats
without encryption, and hide the option to turn it on. Element X and Cinny ignore it, so
Synapse also enforces the policy in rooms created on this server, whoever the sender is,
including users of other servers. It removes encryption from room creation requests, so the
room is created in clear text. It refuses to turn encryption on in an existing room. Upgrading
a room that is already encrypted still works and keeps the encryption.

Rooms already encrypted stay encrypted, the Matrix protocol cannot turn encryption off. Create
a new room to replace them. Rooms created on other servers with federation follow the rules of
their server, local users can encrypt them.

Clients read the file on the user domain. When the user domain differs from
`synapse_domain_name` and points to a website elsewhere, add the `io.element.e2ee` key to the
client file you publish there, see [DNS and web setup](#dns-and-web-setup).

## Voice and video calls

One to one calls need a TURN server when users are behind NAT. The module does not ship one,
but it can use an external TURN server, for example [coturn](https://github.com/coturn/coturn)
configured with `use-auth-secret`. Set `turn_uris` and `turn_shared_secret`. Synapse then gives
short lived TURN credentials to the clients.

The secret is stored in `state/turn.env`. It is never returned by `get-configuration` and it is
included in the backup. With `api-cli`, clearing `turn_uris` keeps the secret, send
`"turn_clear_secret": true` to delete it. In the UI, turning the TURN switch off deletes it.

These legacy calls work only between two people, and Element X does not support them.

### Element Call with LiveKit

With `livekit_enabled`, the module runs a LiveKit media server and lk-jwt-service. Element
Web, Element X and Cinny then make one to one and group calls through Element Call. Element
Web uses Element Call for every call, so it can call Element X users. Clients that only know
legacy calls, like Nheko, can no longer call Element Web users.

Signaling goes through Traefik on the Synapse domain, under `/livekit/sfu` and `/livekit/jwt`.
Media does not. Open or forward these ports to the node:

- 7882/udp, shared by every participant
- 7881/tcp, used when UDP is blocked
- 3478/udp, only with `livekit_turn_enabled`

Enabling LiveKit is refused if another application already uses 7881/tcp or 7882/udp on the
node.

The TURN relay helps clients on networks that block the other ports but allow 3478/udp. It is
refused if another application, for example BigBlueButton, already uses 3478 on the node.
It relays through 1024 UDP ports that NS8 reserves for the instance. They stay closed, there
is nothing to open or forward. Networks that only allow port 443 are not covered.

LiveKit announces the public address found at the last save of the settings. If the lookup
fails, the previous address is kept. Behind NAT, check it in the Settings page and set
`livekit_public_address` if it is wrong.

LiveKit must reach `https://<synapse_domain_name>` from the node to check who joins a call.
The certificate must be valid, a self signed one makes every call fail. In a test lab, send
`"livekit_tls_skip_verify": true` with `api-cli`. Never in production: lk-jwt-service then
also trusts any federated server without checking its certificate. For the same check,
Synapse serves `/.well-known/matrix/server` even with federation off. Other servers then try
to federate and get an error, nothing else is exposed.

For rooms with many participants, raise the kernel UDP buffers on the node, as LiveKit
recommends:

```
sysctl -w net.core.rmem_max=5000000 net.core.wmem_max=5000000
```

As a rough guide, a 50 person call with every camera on needs about 150 Mbit/s of upload.
Audio only calls need far less.

The API key and secret are generated once in `state/livekit.env` and included in the backup.

## Mail

Synapse sends notification mails through the cluster smarthost. `bin/discover-smarthost` runs
when `synapse.service` starts and writes `state/smarthost.env`. The `smarthost-changed` event
restarts Synapse, so connected clients reconnect.

The sender depends on the smarthost:

- smarthost with a username: `mail_from`, or `noreply@<smarthost host>` when empty. TLS is
  required.
- smarthost without a username: `mail_from`, or `noreply@<node FQDN>` when empty. TLS is not
  required.
- no smarthost, or a disabled one: mail is disabled.

## Secrets

`state/matrix-secrets.env` holds the internal secrets. `configure-matrix` creates it when it is
missing.

| Secret | Use |
|---|---|
| `MACAROON_SECRET` | Signs short lived tokens: login tokens, guest tokens, unsubscribe links. Access tokens are stored in the database and do not depend on it. |
| `FORM_SECRET` | Signs the HTML forms served by Synapse. Not used by this setup. |
| `M2A_AS_TOKEN`, `M2A_HS_TOKEN` | Authenticate matrix2acrobits and Synapse to each other. |
| `REGISTRATION_SECRET`, `SYNAPSE_SECRET` | Generated but not used. |

To rotate them, remove the file and run `configure-module` again. Pending short lived tokens
become invalid. Users stay logged in. matrix2acrobits gets the new tokens.

## Backup and restore

The backup contains:

- `state/postgresql.pg_dump`, a `pg_dumpall` taken before each backup
- `state/database.env`, the PostgreSQL password
- `state/config.json`, the last `configure-module` request, without the TURN secret
- `state/turn.env`, the TURN secret
- `state/livekit.env`, the LiveKit API key and secret
- the `synapse-data` volume, with the server signing key and the media
- the `matrix2acrobits-data` volume

The restore loads the dump into a new database, then runs `configure-module` with
`config.json`. `matrix-secrets.env` is not in the backup, so the restore generates new internal
secrets. The effect is the same as a rotation, see [Secrets](#secrets).

A restore or a clone onto a node where another application already uses 7881/tcp or
7882/udp turns Element Call off, and one where 3478/udp is used turns the LiveKit TURN off.
The task logs a warning and the rest of the instance comes back. Free the port, then enable
the option again. A `livekit_public_address` set by hand is restored as is, with a warning:
check it matches the new node.

A restore, a clone or a move turns Let's Encrypt off, because the DNS may still point to the
old node. Enable it again in Settings once the DNS points to the new one.

## Update

An update to a PostgreSQL major version migrates the data automatically. The module dumps the
old database with the previous PostgreSQL image, restores it into the new version and compares
the row counts of `users`, `events` and `rooms`. Synapse and matrix2acrobits are stopped
during the migration.

If the counts differ, the update fails and keeps the dump in `state/upgrade.pg_dump`. Run the
update again to retry, it resumes from the dump. See
[PostgreSQL migration](architecture.md#postgresql-migration) for details.

## Uninstall

```sh
remove-module --no-preserve matrix1
```
