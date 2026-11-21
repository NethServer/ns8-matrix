# configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json
```

Configure Matrix chat service

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                               |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :--------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [configure-module-input.json](matrix/configure-module-input.json "open original schema") |

## configure-module input Type

`object` ([configure-module input](configure-module-input.md))

## configure-module input Examples

```json
{
  "synapse_domain_name": "matrix.example.com",
  "element_domain_name": "chat.example.com",
  "cinny_domain_name": "cinny.example.com",
  "lets_encrypt": true,
  "ldap_domain": "users.example.com",
  "mail_from": "noreply@example.com",
  "nethvoice_auth_url": "https://voice.nethserver.org/freepbx/rest/testextauth",
  "federation": true,
  "federation_whitelist": [
    "example.org"
  ],
  "turn_uris": [
    "turn:turn.example.com:3478?transport=udp"
  ],
  "turn_shared_secret": "",
  "max_upload_size_mb": 50,
  "local_media_lifetime_days": 0,
  "remote_media_lifetime_days": 0,
  "log_level": "INFO",
  "search_all_users": true,
  "livekit_enabled": true,
  "livekit_turn_enabled": false,
  "livekit_public_address": ""
}
```

# configure-module input Properties

| Property                                                  | Type      | Required | Nullable       | Defined by                                                                                                                                                                                         |
| :-------------------------------------------------------- | :-------- | :------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [synapse_domain_name](#synapse_domain_name)               | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/synapse_domain_name")               |
| [matrix_server_name](#matrix_server_name)                 | `string`  | Optional | cannot be null | [configure-module input](configure-module-input-properties-matrix_server_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/matrix_server_name")                 |
| [element_domain_name](#element_domain_name)               | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-element_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/element_domain_name")               |
| [cinny_domain_name](#cinny_domain_name)                   | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/cinny_domain_name")                   |
| [lets_encrypt](#lets_encrypt)                             | `boolean` | Required | cannot be null | [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/lets_encrypt")                             |
| [ldap_domain](#ldap_domain)                               | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-ldap_domain.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/ldap_domain")                               |
| [mail_from](#mail_from)                                   | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-email-from-address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/mail_from")                          |
| [nethvoice_auth_url](#nethvoice_auth_url)                 | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/nethvoice_auth_url")                 |
| [federation](#federation)                                 | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-federation.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/federation")                                 |
| [federation_whitelist](#federation_whitelist)             | `array`   | Optional | cannot be null | [configure-module input](configure-module-input-properties-federation_whitelist.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/federation_whitelist")             |
| [turn_uris](#turn_uris)                                   | `array`   | Optional | cannot be null | [configure-module input](configure-module-input-properties-turn_uris.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_uris")                                   |
| [turn_shared_secret](#turn_shared_secret)                 | `string`  | Optional | cannot be null | [configure-module input](configure-module-input-properties-turn_shared_secret.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_shared_secret")                 |
| [max_upload_size_mb](#max_upload_size_mb)                 | `integer` | Optional | cannot be null | [configure-module input](configure-module-input-properties-max_upload_size_mb.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/max_upload_size_mb")                 |
| [local_media_lifetime_days](#local_media_lifetime_days)   | `integer` | Optional | cannot be null | [configure-module input](configure-module-input-properties-local_media_lifetime_days.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/local_media_lifetime_days")   |
| [remote_media_lifetime_days](#remote_media_lifetime_days) | `integer` | Optional | cannot be null | [configure-module input](configure-module-input-properties-remote_media_lifetime_days.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/remote_media_lifetime_days") |
| [log_level](#log_level)                                   | `string`  | Optional | cannot be null | [configure-module input](configure-module-input-properties-log_level.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/log_level")                                   |
| [search_all_users](#search_all_users)                     | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-search_all_users.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/search_all_users")                     |
| [turn_clear_secret](#turn_clear_secret)                   | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-turn_clear_secret.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_clear_secret")                   |
| [livekit_enabled](#livekit_enabled)                       | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-livekit_enabled.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_enabled")                       |
| [livekit_turn_enabled](#livekit_turn_enabled)             | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-livekit_turn_enabled.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_turn_enabled")             |
| [livekit_public_address](#livekit_public_address)         | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-livekit_public_address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_public_address")         |
| [livekit_tls_skip_verify](#livekit_tls_skip_verify)       | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-livekit_tls_skip_verify.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_tls_skip_verify")       |

## synapse_domain_name

Fully qualified domain name for the Matrix homeserver

`synapse_domain_name`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/synapse_domain_name")

### synapse_domain_name Type

`string`

### synapse_domain_name Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")

## matrix_server_name

User domain, the Synapse server_name in @user:domain. Locked once a user exists. Omitted, the stored value is kept, else synapse_domain_name

`matrix_server_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-matrix_server_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/matrix_server_name")

### matrix_server_name Type

`string`

### matrix_server_name Constraints

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")

## element_domain_name



`element_domain_name`

* is optional

* Type: merged type ([Details](configure-module-input-properties-element_domain_name.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-element_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/element_domain_name")

### element_domain_name Type

merged type ([Details](configure-module-input-properties-element_domain_name.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-element_domain_name-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-element_domain_name-oneof-1.md "check type definition")

## cinny_domain_name



`cinny_domain_name`

* is optional

* Type: merged type ([Details](configure-module-input-properties-cinny_domain_name.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/cinny_domain_name")

### cinny_domain_name Type

merged type ([Details](configure-module-input-properties-cinny_domain_name.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-cinny_domain_name-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-cinny_domain_name-oneof-1.md "check type definition")

## lets_encrypt

Enable Let's Encrypt certificate management

`lets_encrypt`

* is required

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/lets_encrypt")

### lets_encrypt Type

`boolean`

## ldap_domain

LDAP domain name

`ldap_domain`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-ldap_domain.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/ldap_domain")

### ldap_domain Type

`string`

### ldap_domain Constraints

**unknown format**: the value of this string must follow the format: `domain-name`

## mail_from



`mail_from`

* is optional

* Type: `string` ([Email from address](configure-module-input-properties-email-from-address.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-email-from-address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/mail_from")

### mail_from Type

`string` ([Email from address](configure-module-input-properties-email-from-address.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-email-from-address-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-email-from-address-oneof-1.md "check type definition")

## nethvoice_auth_url

NethVoice Authentication URL

`nethvoice_auth_url`

* is optional

* Type: merged type ([Details](configure-module-input-properties-nethvoice_auth_url.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/nethvoice_auth_url")

### nethvoice_auth_url Type

merged type ([Details](configure-module-input-properties-nethvoice_auth_url.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-nethvoice_auth_url-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-nethvoice_auth_url-oneof-1.md "check type definition")

## federation

Allow other Matrix servers to talk with this one

`federation`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-federation.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/federation")

### federation Type

`boolean`

## federation_whitelist

If not empty, federate only with these server names

`federation_whitelist`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-federation_whitelist.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/federation_whitelist")

### federation_whitelist Type

`string[]`

## turn_uris

External TURN server URIs, used for voice and video calls behind NAT

`turn_uris`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-turn_uris.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_uris")

### turn_uris Type

`string[]`

## turn_shared_secret

TURN shared secret (coturn use-auth-secret). An empty value keeps the current secret

`turn_shared_secret`

* is optional

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-turn_shared_secret.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_shared_secret")

### turn_shared_secret Type

`string`

### turn_shared_secret Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^[^\n\r]*$
```

[try pattern](https://regexr.com/?expression=%5E%5B%5E%5Cn%5Cr%5D*%24 "try regular expression with regexr.com")

## max_upload_size_mb

Largest file a user can upload, in megabytes

`max_upload_size_mb`

* is optional

* Type: `integer`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-max_upload_size_mb.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/max_upload_size_mb")

### max_upload_size_mb Type

`integer`

### max_upload_size_mb Constraints

**maximum**: the value of this number must smaller than or equal to: `2048`

**minimum**: the value of this number must greater than or equal to: `1`

## local_media_lifetime_days

Delete local media not accessed for this many days, 0 keeps it forever

`local_media_lifetime_days`

* is optional

* Type: `integer`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-local_media_lifetime_days.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/local_media_lifetime_days")

### local_media_lifetime_days Type

`integer`

### local_media_lifetime_days Constraints

**minimum**: the value of this number must greater than or equal to: `0`

## remote_media_lifetime_days

Delete cached media from other servers not accessed for this many days, 0 keeps it forever

`remote_media_lifetime_days`

* is optional

* Type: `integer`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-remote_media_lifetime_days.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/remote_media_lifetime_days")

### remote_media_lifetime_days Type

`integer`

### remote_media_lifetime_days Constraints

**minimum**: the value of this number must greater than or equal to: `0`

## log_level



`log_level`

* is optional

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-log_level.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/log_level")

### log_level Type

`string`

### log_level Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value       | Explanation |    |    |
| :---------- | :---------- | :- | :- |
| `"INFO"`    |             |
| `"WARNING"` |             |
| `"DEBUG"`   |             |

## search_all_users

Let users find every user who logged in at least once, not only people they share a room with

`search_all_users`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-search_all_users.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/search_all_users")

### search_all_users Type

`boolean`

## turn_clear_secret

Remove the stored TURN shared secret. Ignored when a new turn_shared_secret is sent

`turn_clear_secret`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-turn_clear_secret.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_clear_secret")

### turn_clear_secret Type

`boolean`

## livekit_enabled

Run LiveKit for Element Call voice and video calls

`livekit_enabled`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-livekit_enabled.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_enabled")

### livekit_enabled Type

`boolean`

## livekit_turn_enabled

Enable the LiveKit TURN relay on port 3478/udp. Requires livekit_enabled

`livekit_turn_enabled`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-livekit_turn_enabled.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_turn_enabled")

### livekit_turn_enabled Type

`boolean`

## livekit_public_address

Address announced to call clients. Empty uses the detected public address

`livekit_public_address`

* is optional

* Type: merged type ([Details](configure-module-input-properties-livekit_public_address.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-livekit_public_address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_public_address")

### livekit_public_address Type

merged type ([Details](configure-module-input-properties-livekit_public_address.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-livekit_public_address-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-livekit_public_address-oneof-1.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-livekit_public_address-oneof-2.md "check type definition")

## livekit_tls_skip_verify

Test labs only: let lk-jwt-service accept a self signed Synapse certificate

`livekit_tls_skip_verify`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-livekit_tls_skip_verify.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/livekit_tls_skip_verify")

### livekit_tls_skip_verify Type

`boolean`
