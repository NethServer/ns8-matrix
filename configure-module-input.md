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
  "nethvoice_auth_url": "https://voice.nethserver.org/freepbx/rest/testextauth"
}
```

# configure-module input Properties

| Property                                      | Type      | Required | Nullable       | Defined by                                                                                                                                                                           |
| :-------------------------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [synapse\_domain\_name](#synapse_domain_name) | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/synapse_domain_name") |
| [element\_domain\_name](#element_domain_name) | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-element_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/element_domain_name") |
| [cinny\_domain\_name](#cinny_domain_name)     | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/cinny_domain_name")     |
| [lets\_encrypt](#lets_encrypt)                | `boolean` | Required | cannot be null | [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/lets_encrypt")               |
| [ldap\_domain](#ldap_domain)                  | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-ldap_domain.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/ldap_domain")                 |
| [mail\_from](#mail_from)                      | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-email-from-address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/mail_from")            |
| [nethvoice\_auth\_url](#nethvoice_auth_url)   | Merged    | Optional | cannot be null | [configure-module input](configure-module-input-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/nethvoice_auth_url")   |

## synapse\_domain\_name

Fully qualified domain name for the Matrix homeserver

`synapse_domain_name`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/synapse_domain_name")

### synapse\_domain\_name Type

`string`

### synapse\_domain\_name Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")

## element\_domain\_name



`element_domain_name`

* is optional

* Type: merged type ([Details](configure-module-input-properties-element_domain_name.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-element_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/element_domain_name")

### element\_domain\_name Type

merged type ([Details](configure-module-input-properties-element_domain_name.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-element_domain_name-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-element_domain_name-oneof-1.md "check type definition")

## cinny\_domain\_name



`cinny_domain_name`

* is optional

* Type: merged type ([Details](configure-module-input-properties-cinny_domain_name.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/cinny_domain_name")

### cinny\_domain\_name Type

merged type ([Details](configure-module-input-properties-cinny_domain_name.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-cinny_domain_name-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-cinny_domain_name-oneof-1.md "check type definition")

## lets\_encrypt

Enable Let's Encrypt certificate management

`lets_encrypt`

* is required

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/lets_encrypt")

### lets\_encrypt Type

`boolean`

## ldap\_domain

LDAP domain name

`ldap_domain`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-ldap_domain.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/ldap_domain")

### ldap\_domain Type

`string`

### ldap\_domain Constraints

**unknown format**: the value of this string must follow the format: `domain-name`

## mail\_from



`mail_from`

* is optional

* Type: `string` ([Email from address](configure-module-input-properties-email-from-address.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-email-from-address.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/mail_from")

### mail\_from Type

`string` ([Email from address](configure-module-input-properties-email-from-address.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-email-from-address-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-email-from-address-oneof-1.md "check type definition")

## nethvoice\_auth\_url

NethVoice Authentication URL

`nethvoice_auth_url`

* is optional

* Type: merged type ([Details](configure-module-input-properties-nethvoice_auth_url.md))

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/configure-module-input.json#/properties/nethvoice_auth_url")

### nethvoice\_auth\_url Type

merged type ([Details](configure-module-input-properties-nethvoice_auth_url.md))

one (and only one) of

* [Untitled string in configure-module input](configure-module-input-properties-nethvoice_auth_url-oneof-0.md "check type definition")

* [Untitled string in configure-module input](configure-module-input-properties-nethvoice_auth_url-oneof-1.md "check type definition")
