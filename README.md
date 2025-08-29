# 3scale on ROSA + Cognito

## 1) Pré-requisitos
- Cluster ROSA com o **3scale Operator** instalado
- Namespace `poc` (ou ajuste nos YAMLs)
- Serviços gerenciados:
  - **Aurora PostgreSQL** (endpoints + credenciais)
  - **ElastiCache Redis** com **TLS**
  - **S3** para file storage
- **3scale Toolbox** (`gem install 3scale_toolbox`) ou `curl + jq`
- Domínio **wildcard** do cluster (ex.: `apps.<cluster>.<region>.rosa.aws`)
- Dados do **Cognito**:
  - **Issuer OIDC**: `https://cognito-idp.<region>.amazonaws.com/<userPoolId>`
  - **Domain** para fluxos OAuth2: `https://<COGNITO_DOMAIN>` (usado no OpenAPI para authorize/token)

> Observação: o 3scale usa **issuer OIDC** para validar tokens via *discovery* (JWKs). No Cognito,
> o *issuer* padrão é `https://cognito-idp.<region>.amazonaws.com/<userPoolId>`.

## 2) Instalação do 3scale (Operator)

Aplique os CRs (ajuste os placeholders antes):

```bash
oc project poc
oc apply -f 01-redis-secrets.yaml
oc apply -f 02-db-secrets.yaml
oc apply -f 03-s3-secret.yaml
oc apply -f 20-apimanager.yaml
```

Aguarde os pods ficarem *Ready*. Obtenha a URL do **Admin Portal** para criar o **Access Token** (com permissões *admin*).
