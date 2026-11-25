# Untitled string in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/turn_uris/items
```



| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## items Type

`string`

## items Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^turns?:[^,\s]+$
```

[try pattern](https://regexr.com/?expression=%5Eturns%3F%3A%5B%5E%2C%5Cs%5D%2B%24 "try regular expression with regexr.com")
