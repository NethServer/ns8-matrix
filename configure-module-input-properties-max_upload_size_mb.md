# Untitled integer in configure-module input Schema

```txt
http://schema.nethserver.org/matrix/configure-module-input.json#/properties/max_upload_size_mb
```

Largest file a user can upload, in megabytes

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](matrix/configure-module-input.json "open original schema") |

## max_upload_size_mb Type

`integer`

## max_upload_size_mb Constraints

**maximum**: the value of this number must smaller than or equal to: `2048`

**minimum**: the value of this number must greater than or equal to: `1`
