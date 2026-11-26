# NethVoice integration

## matrix2acrobits

[matrix2acrobits](https://github.com/nethesis/matrix2acrobits) is a Matrix application service
that bridges the Acrobits softphone messaging API to Synapse. It runs when `nethvoice_auth_url`
is set.

- Synapse loads it from `synapse-config/matrix2acrobits.yaml`. The appservice claims no
  exclusive namespace and acts as `@_acrobits_proxy:<matrix_server_name>`.
- It authenticates users against `nethvoice_auth_url`, the NethVoice external auth endpoint,
  for example `https://nethvoice.example.com/freepbx/rest/testextauth`.
- Its settings are in `state/m2a.env`. Its tokens come from `state/matrix-secrets.env`.

Traefik exposes it on the Synapse domain:

| Path | Use |
|---|---|
| `/m2a` | Acrobits messaging API. The prefix is stripped before the request reaches the service. |
| `/_matrix/push/v1/notify` | Push gateway. Synapse sends push notifications here. |

When `nethvoice_auth_url` is cleared, the service is disabled and both routes are deleted.

## Push notifications

matrix2acrobits answers the Matrix push gateway API itself, so the module does not run
[Sygnal](https://github.com/element-hq/sygnal). Whether Sygnal is needed later is still open.

## Roadmap

### Stack

- [Synapse](https://element-hq.github.io/synapse/latest/setup/installation.html) is the de
  facto standard Matrix homeserver.
- Element web is the official Matrix web client. [Cinny](https://cinny.in/) is the
  alternative shipped with the module.

Alternative: [MAS](https://element-hq.github.io/matrix-authentication-service/) would add more
authentication methods (SAML, OIDC, LDAP) and integrate with [authentik](https://goauthentik.io/),
see [authentik integration](https://integrations.goauthentik.io/chat-communication-collaboration/matrix-synapse/)
and [MAS SSO setup](https://element-hq.github.io/matrix-authentication-service/setup/sso.html#authentik).

### To be done

If the current stack is kept, NethVoice CTI integration needs:

- testing the available client integrations: [Chatterbox](https://github.com/element-hq/chatterbox),
  [Cactus](https://cactus.chat/), or the plain [JavaScript SDK](https://github.com/matrix-org/matrix-js-sdk)
- authentication, two possible ways:
  - OIDC in the [CTI middleware](https://github.com/nethesis/nethcti-middleware): the user
    authenticates against the OAuth 2 provider (like authentik, if 2FA is required) and the
    middleware uses the ID token to authenticate against Synapse
  - plain LDAP: the CTI middleware also authenticates against Synapse with the LDAP
    credentials

### Future improvements

- WhatsApp bridge with [mautrix-whatsapp](https://github.com/mautrix/whatsapp)
- Telegram bridge with [mautrix-telegram](https://github.com/mautrix/telegram)
- A consolidated bridges image, see [container-matrix-bridges](https://github.com/nfrastack/container-matrix-bridges)
