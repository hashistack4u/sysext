#!/usr/bin/env bash
set -euo pipefail

CONSUL_TEMPLATE_VERSION="0.39.1"
CONSUL_VERSION="1.20.2"
NOMAD_VERSION="1.9.5"
VAULT_VERSION="1.18.4"
LOKI_VERSION="3.3.2"

TMP=$(mktemp -d)
mkdir -p $TMP/usr/bin

# Actual HashiStack
wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O $TMP/consul-template.zip
unzip -o $TMP/consul-template.zip -d $TMP/usr/bin
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O $TMP/consul.zip
unzip -o $TMP/consul.zip -d $TMP/usr/bin
wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -O $TMP/nomad.zip
unzip -o $TMP/nomad.zip -d $TMP/usr/bin
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O $TMP/vault.zip
unzip -o $TMP/vault.zip -d $TMP/usr/bin

# Addons
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip -O $TMP/loki.zip
unzip -o $TMP/loki.zip -d $TMP/usr/bin
mv $TMP/usr/bin/loki-linux-amd64 $TMP/usr/bin/loki
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip -O $TMP/promtail.zip
unzip -o $TMP/promtail.zip -d $TMP/usr/bin
mv $TMP/usr/bin/promtail-linux-amd64 $TMP/usr/bin/promtail


rm $TMP/*.zip
mkdir hashistack
mv $TMP/* hashistack/
RELOAD=1 ./bake.sh hashistack
rm -rf "hashistack"
sha256sum hashistack.raw | tee hashistack.raw.DIGESTS

echo "# Release $(date '+%Y-%m-%d %R')" > Release.md
echo "The release adds the following components:" >> Release.md
echo "[HashiCorp Consul-template ${CONSUL_TEMPLATE_VERSION}](https://github.com/hashicorp/consul-template/releases/tag/v${CONSUL_TEMPLATE_VERSION})" >> Release.md
echo "[HashiCorp Consul ${CONSUL_VERSION}](https://github.com/hashicorp/consul/releases/tag/v${CONSUL_VERSION})" >> Release.md
echo "[HashiCorp Nomad ${NOMAD_VERSION}](https://github.com/hashicorp/nomad/releases/tag/v${NOMAD_VERSION})" >> Release.md
echo "[HashiCorp Vault ${VAULT_VERSION}](https://github.com/hashicorp/vault/releases/tag/v${VAULT_VERSION})" >> Release.md
echo "[Grafana Loki ${LOKI_VERSION}](https://github.com/grafana/loki/releases/tag/v${LOKI_VERSION})" >> Release.md
echo "" >> Release.md
echo "Binaries inside of image are using following licenses:" >> Release.md
echo "* HashiCorp binaries, [Business Source License](https://www.hashicorp.com/en/bsl)" >> Release.md
echo "* Grafana binaries, [AGPLv3](https://grafana.com/licensing/)" >> Release.md
