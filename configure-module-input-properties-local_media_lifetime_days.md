# Untitled integer in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/local_media_lifetime_days
```

Delete local media not accessed for this many days, 0 keeps it forever

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## local_media_lifetime_days Type

`integer`

## local_media_lifetime_days Constraints

**minimum**: the value of this number must greater than or equal to: `0`
