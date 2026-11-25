# Untitled string in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_shared_secret
```

TURN shared secret (coturn use-auth-secret). An empty value keeps the current secret

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## turn_shared_secret Type

`string`

## turn_shared_secret Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^[^\n\r]*$
```

[try pattern](https://regexr.com/?expression=%5E%5B%5E%5Cn%5Cr%5D*%24 "try regular expression with regexr.com")
