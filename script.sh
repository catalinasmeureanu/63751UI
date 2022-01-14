#!/bin/bash -x
set -aex

# start vault dev server
vault server -dev -dev-root-token-id="root"&

sleep 2

export VAULT_ADDR='http://127.0.0.1:8200'

vault login root

vault namespace create education

# create admin policy that doesn't have access to read the policy edu-admin

cat > admin-policy.hcl <<EOF
# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/edu-admin" {
   capabilities = ["deny"]
}
EOF

vault policy write -namespace=education admin admin-policy.hcl

# create a token with admin policy
vault token create -namespace=education  -policy=admin

cat > edu-admin.hcl <<EOF
path "*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

vault policy write -namespace=education edu-admin edu-admin.hcl