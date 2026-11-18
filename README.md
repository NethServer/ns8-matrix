# ns8-matrix

:warning: This project is just a proof of concept to evaluate Matrix integration with NethServer 8.
The goal is to provide a chat engine for NethVoice and NethCTI modules in the future: see https://github.com/NethServer/dev/issues/7648.
This module is in early development and should be used for testing purposes only. Do not use in production environments. :warning:

A NethServer 8 module for [Matrix](https://matrix.org/) chat service integration with LDAP authentication.

This module provides a complete Matrix chat solution including:
- **Synapse** (Matrix Homeserver) - Core Matrix server
- **Element Web** (Web Client) - Web interface for Matrix chat
- **Cinny** (Web Client) - Alternative web interface for Matrix chat

## Features

- Seamless integration with NethServer 8 LDAP user directory
- Configurable domain names for the Matrix server and the Element and Cinny web clients
- Automatic SSL/TLS certificate management via Traefik
- Optional Matrix federation, delegated through `/.well-known` on port 443
- Optional external TURN server for voice and video calls behind NAT
- Upload size, media retention and log level settings
- Persistent data storage
- Postgresql database backend

## Install

Instantiate the module with:

    add-module ghcr.io/nethserver/matrix:latest 1

The output of the command will return the instance name.
Output example:

    {"module_id": "matrix1", "image_name": "matrix", "image_url": "ghcr.io/nethserver/matrix:latest"}

## Configure

Let's assume that the matrix instance is named `matrix1`.

Launch `configure-module`, by setting the following parameters:
- `synapse_domain_name`: The fully qualified domain name for the Matrix server (e.g., `matrix.example.com`)
- `element_domain_name`: The fully qualified domain name for the Element web client (e.g., `chat.example.com`). Leave empty to disable Element.
- `cinny_domain_name`: The fully qualified domain name for the Cinny client (e.g., `cinny.example.com`). Leave empty to disable Cinny.
- `lets_encrypt`: Set to `true` to request Let's Encrypt certificates for all the configured domains.
- `ldap_domain`: The LDAP domain name to be used for authentication.
- `mail_from`: The mail sender address for notification mails
- `nethvoice_auth_url`: The NethVoice authentication URL to enable NethVoice integration, if set the `matrix2acrobits` service will be configured and started.
- `federation`: Set to `true` to let users talk with other Matrix servers, see [Matrix Federation](#matrix-federation). Default `false`.
- `federation_whitelist`: Optional list of server names allowed to federate. Empty means any server.
- `turn_uris`: Optional list of external TURN server URIs, see [Voice and video calls](#voice-and-video-calls).
- `turn_shared_secret`: The TURN shared secret. Required the first time `turn_uris` is set, an empty value keeps the stored secret.
- `max_upload_size_mb`: Largest file a user can upload, in megabytes. Default `50`.
- `local_media_lifetime_days`: Delete uploaded files not viewed for this many days. Default `0`, which keeps them forever.
- `remote_media_lifetime_days`: Delete cached files from other servers not viewed for this many days. Default `0`, which keeps them forever.
- `search_all_users`: Let users find every user of the LDAP domain, not only people they share a room with. Default `true` for new instances, existing instances keep `false` until it is changed. Only users who logged in at least once can be found, Synapse does not search the LDAP directory itself.
- `log_level`: `INFO`, `WARNING` or `DEBUG`. Default `INFO`.

All the new parameters are optional, a request without them keeps the defaults.

Example:

    api-cli run module/matrix1/configure-module --data '{"synapse_domain_name": "matrix.example.com", "element_domain_name": "chat.example.com", "cinny_domain_name": "cinny.example.com", "lets_encrypt": true, "ldap_domain": "users.example.com", "mail_from": "noreply@example.com", "nethvoice_auth_url": "https://nethvoice.nethserver.org/freepbx/rest/testextauth"}'

The above command will:
- Start and configure the Synapse Matrix homeserver with LDAP authentication
- Deploy Element Web client and Cinny client configured to connect to the local Synapse instance
- Set up Traefik routes for the three domains with automatic SSL certificates
- Start Matrix2Acrobits Application Service

Access your Matrix installation:
- Matrix server: `https://matrix.example.com`
- Element web client: `https://chat.example.com`
- Cinny client: `https://cinny.example.com`

## Web clients

Two web clients are available, Element web and Cinny. A client is enabled when its domain name is set, in the UI or with `element_domain_name` and `cinny_domain_name`. An empty domain name disables it.

### Element web client

The Element client supports customized themes, examples are added to the configuration file in `element-config/config.json`.

```
"custom_themes": [
            {
                "name": "NethServer1",
                "is_dark": false,
                "fonts": {
                    "faces": [
                        {
                            "font-family": "Inter",
                            "src": [{"url": "/fonts/Inter.ttf", "format": "ttf"}]
                        }
                    ],
                    "general": "Inter, sans",
                    "monospace": "'Courier New'"
                },
                "colors": {
                    "accent-color": "#3596fc",
                    "primary-color": "#368bd6",
                    "warning-color": "#ff4b55",
                    "sidebar-color": "#27303a",
                    "roomlist-background-color": "#f3f8fd",
                    "roomlist-text-color": "#2e2f32",
                    "roomlist-text-secondary-color": "#61708b",
                    "roomlist-highlights-color": "#ffffff",
                    "roomlist-separator-color": "#e3e8f0",
                    "timeline-background-color": "#ffffff",
                    "timeline-text-color": "#2e2f32",
                    "timeline-text-secondary-color": "#61708b",
                    "timeline-highlights-color": "#f3f8fd"
                },
                "compound": {
                    "--cpd-color-icon-accent-tertiary": "var(--cpd-color-blue-800)",
                    "--cpd-color-text-action-accent": "var(--cpd-color-blue-900)"
                }
            }
]
```

### Cinny Client

Cinny is an alternative web client for Matrix chat, included in this module to provide users with a modern, lightweight interface. It can be accessed via a web browser and supports essential Matrix features such as messaging and rooms. Cinny is pre-configured to work with the Synapse server, users log in with their LDAP user name and password.

## LDAP Integration

The module automatically discovers LDAP settings from the NethServer 8 configuration. 
Synapse is configured to connect to the NS8 LDAP proxy to authenticate users against 
the centralized user directory.

The LDAP discovery happens every time the services start through the `bin/discover-ldap` 
script, which refreshes the `state/ldap.env` file with current LDAP configuration.

When the LDAP settings of the cluster change, the event handler
`events/ldap-changed/10reload_services` restarts Synapse, which reads the
new settings at startup. Any LDAP change in the cluster triggers it, not
only changes to the domain used by Matrix.

## Matrix Federation

Federation is disabled by default: users can only talk with accounts of this server.

When `federation` is enabled, Synapse serves the federation API and answers
`/.well-known/matrix/server` with `<synapse_domain_name>:443`. Other servers reach
this one through the existing Traefik route on port 443, port 8448 is not needed.

Requirements:
- a public DNS record for `synapse_domain_name`
- a valid certificate for it, other servers refuse self-signed certificates
- do not change `synapse_domain_name` once federation is in use, it is part of every user ID and of the server signing key

Use `federation_whitelist` to federate only with known partners. You can check
the setup with the [Matrix Federation Tester](https://federationtester.matrix.org/).

## Voice and video calls

One to one calls need a TURN server when users are behind NAT. The module does
not ship one, but it can use an external TURN server, for example
[coturn](https://github.com/coturn/coturn) configured with `use-auth-secret`.
Set `turn_uris` and `turn_shared_secret`, Synapse then gives short lived TURN
credentials to the clients.

The secret is stored in `state/turn.env`, it is never returned by
`get-configuration` and it is included in the backup. Clearing `turn_uris`
keeps the secret, send `"turn_clear_secret": true` (or use the "Remove stored
secret" button) to delete it.

Group calls with Element Call use a different technology (LiveKit) and are not covered.

## Rotate/recreate secrets

The secrets are stored in `matrix-secrets.env`. To rotate them, remove the file and run `configure-module` again: it is recreated with new secrets.

Rotating them has side effects:
- `MACAROON_SECRET` and `FORM_SECRET` sign short lived tokens (login tokens, form submissions), any pending one becomes invalid. Access tokens are stored in the database, so users stay logged in
- `M2A_AS_TOKEN` and `M2A_HS_TOKEN` change, and matrix2acrobits is reconfigured with the new values

`REGISTRATION_SECRET` and `SYNAPSE_SECRET` are generated but not used by the current configuration.

## Uninstall

To uninstall the instance:

    remove-module --no-preserve matrix1

## Running tests locally

This module uses the NS8 standard testing infrastructure. For instructions on how to run the test suite locally, refer to the [Running tests locally](https://github.com/NethServer/ns8-github-actions/blob/v1/README.md#running-tests-locally) section of the ns8-github-actions repository.

## UI translation

Translated with [Weblate](https://hosted.weblate.org/projects/ns8/).

To setup the translation process:

- add [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- add your repository to [hosted.weblate.org]((https://hosted.weblate.org) or ask a NethServer developer to add it to ns8 Weblate project

## Next steps and potential improvements

Stack explanation:
- [Synapse](https://element-hq.github.io/synapse/latest/setup/installation.html) is the standard de-fact Matrix homeserver implementation
- Element web is the official Matrix web client, it can be replaced with other web client clients like [Cinny](https://cinny.in/)

Alternative stacks:
- Use [MAS](https://element-hq.github.io/matrix-authentication-service/) to add more authentication methods (SAML, OIDC, LDAP, etc.) and integrate with [authentik](https://goauthentik.io/) [1](https://integrations.goauthentik.io/chat-communication-collaboration/matrix-synapse/) [2](https://element-hq.github.io/matrix-authentication-service/setup/sso.html#authentik)

### To be done

If the current stack will be used, the following must be made.

NethVoice CTI integration:
- test current available client integrations
  - [Chatterbox](https://github.com/element-hq/chatterbox)
  - [Cactus](https://cactus.chat/)
  - Plain [Javascript SDK](https://github.com/matrix-org/matrix-js-sdk)
- implement authentication, there 2 possible ways:
  - add support for OIDC ID inside [CTI middleware](https://github.com/nethesis/nethcti-middleware): the user authenticate against the Oauth 2 provider (like authentik, if 2FA is required) and the middleware uses the ID token to authenticate against Synapse with the obtained token
  - use normal LDAP auhtentication: the CTI middleware takes care also to authenticate against Synapse using LDAP credentials

### Future improvements

- Evaluate if [Sygnal Push Gateway](https://github.com/element-hq/sygnal) is required (it should not)
- Add support for group calls with [Element Call](https://github.com/element-hq/element-call)
- Add Whatsapp Bridge with [mautrix-whatsapp](https://github.com/mautrix/whatsapp)
- Add Telegram Bridge with [mautrix-telegram](https://github.com/mautrix/telegram)
- Considerations for Implementing consolidated Matrix Bridges, Image: [MAtrix Bridges Image ](https://github.com/nfrastack/container-matrix-bridges)
