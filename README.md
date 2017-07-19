# appd-mark-node-historical
A simple script to mark a node as historical based on app and node names.

# Installation
#### Permissions
```
chmod u+x mark-node-historical.sh
```

#### Update Your config-mark-node-historical.ini
This file stores your configs and Controller access credentials. Update the various fields as appropriate for your Controllers. FYI, many on premises Controllers simply have 'customer1' as the account name.

```
readonly USERNAME="admin"
readonly PASSWORD="admin"
readonly ACCOUNT="customer1"
readonly CONTROLLER="http://controller.example.com:8090"

# Toggle true|false to enable debug logging
readonly DEBUG_LOGS=false
```

# Usage
`mark-node-historical.sh <APP_NAME> <NODE_NAME>`

## Examples
`mark-node-historical.sh myAppName myNodeName`

`mark-node-historical.sh myAppName $HOSTNAME`
