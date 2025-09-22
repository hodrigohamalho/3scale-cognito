#!/bin/bash

# echo "Create keycloak namespace"
# oc create -f keycloak/00-namespace.yaml

# echo "Create POSTGRES"
# oc create -f keycloak/10-postgres-pvc.yaml
# oc create -f keycloak/15-postgres-secret.yaml

# echo "Create Keycloak"
# oc create -f keycloak/20-postgres.yaml

echo "Create Keycloak"
# oc create -f keycloak/40-keycloak-cr.yaml

echo "Create 3Scale namespace "
oc create -f 00-namespace.yaml
echo "Create RWO System Storage (workaround to RWX 3scale storage need) "
oc create -f 03-system-storage.yaml
oc create -f 04-apimanager-cr.yaml
