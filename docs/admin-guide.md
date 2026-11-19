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
| `synapse_domain_name` | required | FQDN of the Matrix server, for example `matrix.example.com`. It becomes part of every user ID. |
| `lets_encrypt` | required | Request Let's Encrypt certificates for all the configured domains. |
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
| `max_upload_size_mb` | `50` | Largest file a user can upload, in megabytes. |
| `local_media_lifetime_days` | `0` | Delete uploaded files not viewed for this many days. `0` keeps them forever. |
| `remote_media_lifetime_days` | `0` | Delete cached files from other servers not viewed for this many days. `0` keeps them forever. |
| `search_all_users` | see below | Let users find every user of the LDAP domain, not only people they share a room with. |
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

Two keys behave differently:

- `turn_shared_secret`: missing or empty keeps the stored secret.
- `search_all_users`: missing keeps the stored value. An instance without a stored value gets
  `false`. The UI shows `true` for a new instance, so a module configured from the UI gets
  `true`. Only users who logged in at least once can be found, Synapse does not search the
  LDAP directory itself.

### Validation errors

`turn_shared_secret_required`: `turn_uris` is set but there is no secret, in the request or
stored. The module is left untouched.

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

## Federation

Federation is disabled by default: users can only talk with accounts of this server.

When `federation` is enabled, Synapse serves the federation API and answers
`/.well-known/matrix/server` with `<synapse_domain_name>:443`. Other servers reach this one
through the existing Traefik route on port 443. Port 8448 is not needed.

Requirements:

- a public DNS record for `synapse_domain_name`
- a valid certificate for it, other servers refuse self-signed certificates
- do not change `synapse_domain_name` once federation is in use, it is part of every user ID
  and of the server signing key

Use `federation_whitelist` to federate only with known partners. Check the setup with the
[Matrix Federation Tester](https://federationtester.matrix.org/).

## Voice and video calls

One to one calls need a TURN server when users are behind NAT. The module does not ship one,
but it can use an external TURN server, for example [coturn](https://github.com/coturn/coturn)
configured with `use-auth-secret`. Set `turn_uris` and `turn_shared_secret`. Synapse then gives
short lived TURN credentials to the clients.

The secret is stored in `state/turn.env`. It is never returned by `get-configuration` and it is
included in the backup. With `api-cli`, clearing `turn_uris` keeps the secret, send
`"turn_clear_secret": true` to delete it. In the UI, turning the TURN switch off deletes it.

Group calls with Element Call use a different technology (LiveKit) and are not covered.

## Mail

Synapse sends notification mails through the cluster smarthost. `bin/discover-smarthost` runs
when `synapse.service` starts and writes `state/smarthost.env`. The `smarthost-changed` event
reloads Synapse.

When `mail_from` is empty, the sender is `noreply@<smarthost host>`, or `noreply@<node FQDN>`
when no smarthost is set.

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
- the `synapse-data` volume, with the server signing key and the media
- the `matrix2acrobits-data` volume

The restore loads the dump into a new database, then runs `configure-module` with
`config.json`. `matrix-secrets.env` is not in the backup, so the restore generates new internal
secrets. The effect is the same as a rotation, see [Secrets](#secrets).

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
