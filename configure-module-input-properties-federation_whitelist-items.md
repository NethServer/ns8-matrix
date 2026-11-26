# Untitled string in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/federation_whitelist/items
```

Matrix server name: host name or IP address, optionally followed by :port

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## items Type

`string`

## items Constraints

**maximum length**: the maximum number of characters for this string is: `255`

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^(\[[0-9a-fA-F:.]+\]|[A-Za-z0-9.-]+)(:[0-9]{1,5})?$
```

[try pattern](https://regexr.com/?expression=%5E\(%5C%5B%5B0-9a-fA-F%3A.%5D%2B%5C%5D%7C%5BA-Za-z0-9.-%5D%2B\)\(%3A%5B0-9%5D%7B1%2C5%7D\)%3F%24 "try regular expression with regexr.com")
