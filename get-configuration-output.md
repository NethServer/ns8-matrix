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

| Property                                      | Type      | Required | Nullable       | Defined by                                                                                                                                                                                 |
| :-------------------------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [synapse\_domain\_name](#synapse_domain_name) | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/synapse_domain_name") |
| [element\_domain\_name](#element_domain_name) | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-element_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/element_domain_name") |
| [cinny\_domain\_name](#cinny_domain_name)     | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/cinny_domain_name")     |
| [lets\_encrypt](#lets_encrypt)                | `boolean` | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/lets_encrypt")               |
| [ldap\_domain](#ldap_domain)                  | `string`  | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-ldap_domain.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/ldap_domain")                 |
| [mail\_from](#mail_from)                      | Merged    | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-email-from-address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/mail_from")            |
| [nethvoice\_auth\_url](#nethvoice_auth_url)   | Merged    | Optional | cannot be null | [get-configuration output](get-configuration-output-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/nethvoice_auth_url")   |

## synapse\_domain\_name

Fully qualified domain name for the Matrix homeserver

`synapse_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-synapse_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/synapse_domain_name")

### synapse\_domain\_name Type

`string`

## element\_domain\_name

Fully qualified domain name for the Element web client

`element_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-element_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/element_domain_name")

### element\_domain\_name Type

`string`

## cinny\_domain\_name

Fully qualified domain name for the Cinny client

`cinny_domain_name`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-cinny_domain_name.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/cinny_domain_name")

### cinny\_domain\_name Type

`string`

## lets\_encrypt

Enable Let's Encrypt certificate management

`lets_encrypt`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/lets_encrypt")

### lets\_encrypt Type

`boolean`

## ldap\_domain

LDAP domain name

`ldap_domain`

* is optional

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-ldap_domain.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/ldap_domain")

### ldap\_domain Type

`string`

### ldap\_domain Constraints

**unknown format**: the value of this string must follow the format: `domain-name`

## mail\_from



`mail_from`

* is optional

* Type: `string` ([Email from address](get-configuration-output-properties-email-from-address.md))

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-email-from-address.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/mail_from")

### mail\_from Type

`string` ([Email from address](get-configuration-output-properties-email-from-address.md))

one (and only one) of

* [Untitled string in get-configuration output](get-configuration-output-properties-email-from-address-oneof-0.md "check type definition")

* [Untitled string in get-configuration output](get-configuration-output-properties-email-from-address-oneof-1.md "check type definition")

## nethvoice\_auth\_url

NethVoice Authentication URL

`nethvoice_auth_url`

* is optional

* Type: merged type ([Details](get-configuration-output-properties-nethvoice_auth_url.md))

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-nethvoice_auth_url.md "http://schema.nethserver.org/matrix/get-configuration-output.json#/properties/nethvoice_auth_url")

### nethvoice\_auth\_url Type

merged type ([Details](get-configuration-output-properties-nethvoice_auth_url.md))

one (and only one) of

* [Untitled string in get-configuration output](get-configuration-output-properties-nethvoice_auth_url-oneof-0.md "check type definition")

* [Untitled string in get-configuration output](get-configuration-output-properties-nethvoice_auth_url-oneof-1.md "check type definition")
