# Untitled string in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/matrix_server_name
```

User domain, the Synapse server_name in @user:domain. Locked once a user exists. Omitted, the stored value is kept, else synapse_domain_name

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## matrix_server_name Type

`string`

## matrix_server_name Constraints

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")
