# get-configuration output Schema

```txt
http://schema.nethserver.org/matrix/get-configuration-output.json
```

Get Matrix configuration

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                   |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [get-configuration-output.json](matrix/get-configuration-output.json "open original schema") |

## get-configuration output Type

`object` ([get-configuration output](get-configuration-output.md))

## get-configuration output Examples

```json
{
  "synapse_domain_name": "matrix.example.com",
  "element_domain_name": "chat.example.com",
  "cinny_domain_name": "cinny.example.com",
  "lets_encrypt": true,
  "ldap_domain": "users.example.com",
  "mail_from": "noreply@example.com"
}
```

# get-configuration output Properties

| Property                                                  | Type      | Required | Nullable       | Defined by                                                                                                                                                                                               |
| :-------------------------------------------------------- | :-------- | :------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [synapse_domain_name](#synapse_domain_name)               | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/synapse_domain_name")               |
| [element_domain_name](#element_domain_name)               | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-element_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/element_domain_name")               |
| [cinny_domain_name](#cinny_domain_name)                   | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/cinny_domain_name")                   |
| [lets_encrypt](#lets_encrypt)                             | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/lets_encrypt")                             |
| [ldap_domain](#ldap_domain)                               | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-ldap_domain.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/ldap_domain")                               |
| [mail_from](#mail_from)                                   | Merged    | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-email-from-address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/mail_from")                          |
| [nethvoice_auth_url](#nethvoice_auth_url)                 | Merged    | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/nethvoice_auth_url")                 |
| [federation](#federation)                                 | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-federation.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/federation")                                 |
| [federation_whitelist](#federation_whitelist)             | `array`   | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-federation_whitelist.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/federation_whitelist")             |
| [turn_uris](#turn_uris)                                   | `array`   | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-turn_uris.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/turn_uris")                                   |
| [turn_shared_secret_set](#turn_shared_secret_set)         | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-turn_shared_secret_set.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/turn_shared_secret_set")         |
| [max_upload_size_mb](#max_upload_size_mb)                 | `integer` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-max_upload_size_mb.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/max_upload_size_mb")                 |
| [local_media_lifetime_days](#local_media_lifetime_days)   | `integer` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-local_media_lifetime_days.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/local_media_lifetime_days")   |
| [remote_media_lifetime_days](#remote_media_lifetime_days) | `integer` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-remote_media_lifetime_days.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/remote_media_lifetime_days") |
| [log_level](#log_level)                                   | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-log_level.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/log_level")                                   |
| [search_all_users](#search_all_users)                     | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-search_all_users.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/search_all_users")                     |
| [livekit_enabled](#livekit_enabled)                       | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_enabled.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_enabled")                       |
| [livekit_turn_enabled](#livekit_turn_enabled)             | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_turn_enabled.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_turn_enabled")             |
| [livekit_public_address](#livekit_public_address)         | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_public_address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_public_address")         |
| [livekit_detected_address](#livekit_detected_address)     | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_detected_address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_detected_address")     |
| [livekit_ports](#livekit_ports)                           | `array`   | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_ports.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_ports")                           |
| [livekit_tls_skip_verify](#livekit_tls_skip_verify)       | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_tls_skip_verify.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_tls_skip_verify")       |
| [livekit_ports_in_use](#livekit_ports_in_use)             | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_ports_in_use.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_ports_in_use")             |
| [livekit_turn_port_in_use](#livekit_turn_port_in_use)     | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-livekit_turn_port_in_use.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_turn_port_in_use")     |

## synapse_domain_name

Fully qualified domain name for the Matrix homeserver

`synapse_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/synapse_domain_name")

### synapse_domain_name Type

`string`

## element_domain_name

Fully qualified domain name for the Element web client

`element_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-element_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/element_domain_name")

### element_domain_name Type

`string`

## cinny_domain_name

Fully qualified domain name for the Cinny client

`cinny_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/cinny_domain_name")

### cinny_domain_name Type

`string`

## lets_encrypt

Enable Let's Encrypt certificate management

`lets_encrypt`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/lets_encrypt")

### lets_encrypt Type

`boolean`

## ldap_domain

LDAP domain name

`ldap_domain`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-ldap_domain.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/ldap_domain")

### ldap_domain Type

`string`

### ldap_domain Constraints

**unknown format**: the value of this string must follow the format: `domain-name`

## mail_from



`mail_from`

* is optional

* Type: `string` ([Email from address](get-configuration-output-properties-email-from-address.md))

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-email-from-address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/mail_from")

### mail_from Type

`string` ([Email from address](get-configuration-output-properties-email-from-address.md))

one (and only one) of

* [Untitled string in get-configuration output](get-configuration-output-properties-email-from-address-oneof-0.md "check type definition")

* [Untitled string in get-configuration output](get-configuration-output-properties-email-from-address-oneof-1.md "check type definition")

## nethvoice_auth_url

NethVoice Authentication URL

`nethvoice_auth_url`

* is optional

* Type: merged type ([Details](get-configuration-output-properties-nethvoice_auth_url.md))

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/nethvoice_auth_url")

### nethvoice_auth_url Type

merged type ([Details](get-configuration-output-properties-nethvoice_auth_url.md))

one (and only one) of

* [Untitled string in get-configuration output](get-configuration-output-properties-nethvoice_auth_url-oneof-0.md "check type definition")

* [Untitled string in get-configuration output](get-configuration-output-properties-nethvoice_auth_url-oneof-1.md "check type definition")

## federation



`federation`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-federation.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/federation")

### federation Type

`boolean`

## federation_whitelist



`federation_whitelist`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-federation_whitelist.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/federation_whitelist")

### federation_whitelist Type

`string[]`

## turn_uris



`turn_uris`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-turn_uris.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/turn_uris")

### turn_uris Type

`string[]`

## turn_shared_secret_set

True if a TURN secret is stored. The secret itself is never returned

`turn_shared_secret_set`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-turn_shared_secret_set.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/turn_shared_secret_set")

### turn_shared_secret_set Type

`boolean`

## max_upload_size_mb



`max_upload_size_mb`

* is optional

* Type: `integer`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-max_upload_size_mb.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/max_upload_size_mb")

### max_upload_size_mb Type

`integer`

## local_media_lifetime_days



`local_media_lifetime_days`

* is optional

* Type: `integer`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-local_media_lifetime_days.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/local_media_lifetime_days")

### local_media_lifetime_days Type

`integer`

## remote_media_lifetime_days



`remote_media_lifetime_days`

* is optional

* Type: `integer`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-remote_media_lifetime_days.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/remote_media_lifetime_days")

### remote_media_lifetime_days Type

`integer`

## log_level



`log_level`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-log_level.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/log_level")

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

* defined in: [get-configuration output](get-configuration-output-properties-search_all_users.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/search_all_users")

### search_all_users Type

`boolean`

## livekit_enabled



`livekit_enabled`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_enabled.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_enabled")

### livekit_enabled Type

`boolean`

## livekit_turn_enabled



`livekit_turn_enabled`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_turn_enabled.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_turn_enabled")

### livekit_turn_enabled Type

`boolean`

## livekit_public_address



`livekit_public_address`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_public_address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_public_address")

### livekit_public_address Type

`string`

## livekit_detected_address

Public address found by the last detection, empty if none

`livekit_detected_address`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_detected_address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_detected_address")

### livekit_detected_address Type

`string`

## livekit_ports

Ports to open or forward to this node, like 7881/tcp

`livekit_ports`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_ports.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_ports")

### livekit_ports Type

`string[]`

## livekit_tls_skip_verify



`livekit_tls_skip_verify`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_tls_skip_verify.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_tls_skip_verify")

### livekit_tls_skip_verify Type

`boolean`

## livekit_ports_in_use

True if another application holds 7881/tcp or 7882/udp. Only checked while LiveKit is off

`livekit_ports_in_use`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_ports_in_use.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_ports_in_use")

### livekit_ports_in_use Type

`boolean`

## livekit_turn_port_in_use

True if another application holds 3478/udp. Only checked while the TURN relay is off

`livekit_turn_port_in_use`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-livekit_turn_port_in_use.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/livekit_turn_port_in_use")

### livekit_turn_port_in_use Type

`boolean`
