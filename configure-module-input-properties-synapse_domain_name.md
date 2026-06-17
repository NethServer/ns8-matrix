# Untitled string in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/synapse_domain_name
```

Fully qualified domain name for the Matrix homeserver

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## synapse\_domain\_name Type

`string`

## synapse\_domain\_name Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")
