#!/usr/bin/env bash
set -euo pipefail

# Versions
## HashiStack
CONSUL_TEMPLATE_VERSION="0.39.1"
CONSUL_VERSION="1.20.2"
NOMAD_VERSION="1.9.5"
VAULT_VERSION="1.18.4"

## CNI plugins
CNI_PLUGINS_VERSION="1.6.2"
AZURE_CNI_PLUGINS_VERSION="1.6.20"

## Addons
COREDNS_VERSION="1.12.0"
LOKI_VERSION="3.3.2"
AZURE_KEY_VAULT_AGENT_VERSION="1.8.0"
DMIDECODE_VERSION="3.6"


mkdir -p hashistack/usr/bin
mkdir -p hashistack/usr/lib/cni
WORKDIR=$(pwd)

# Actual HashiStack
wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O hashistack/consul-template.zip
unzip -o hashistack/consul-template.zip -d hashistack/usr/bin
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O hashistack/consul.zip
unzip -o hashistack/consul.zip -d hashistack/usr/bin
wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -O hashistack/nomad.zip
unzip -o hashistack/nomad.zip -d hashistack/usr/bin
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O hashistack/vault.zip
unzip -o hashistack/vault.zip -d hashistack/usr/bin

# CNI plugins
wget https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-v${CNI_PLUGINS_VERSION}.tgz -O hashistack/cni-plugins.tgz
tar -zxvf hashistack/cni-plugins.tgz -C hashistack/usr/lib/cni
wget https://github.com/Azure/azure-container-networking/releases/download/v${AZURE_CNI_PLUGINS_VERSION}/azure-vnet-cni-linux-amd64-v${AZURE_CNI_PLUGINS_VERSION}.tgz -O hashistack/azure-vnet-cni.tgz
tar -zxvf hashistack/azure-vnet-cni.tgz -C hashistack/usr/lib/cni
rm -f hashistack/usr/lib/cni/10-azure.conflist
rm -f hashistack/usr/lib/cni/azure-vnet-telemetry.config

# Addons
wget https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz -O hashistack/coredns.tgz
tar -zxvf hashistack/coredns.tgz -C hashistack/usr/bin
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip -O hashistack/loki.zip
unzip -o hashistack/loki.zip -d hashistack/usr/bin
mv hashistack/usr/bin/loki-linux-amd64 hashistack/usr/bin/loki
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip -O hashistack/promtail.zip
unzip -o hashistack/promtail.zip -d hashistack/usr/bin
mv hashistack/usr/bin/promtail-linux-amd64 hashistack/usr/bin/promtail
wget https://github.com/covermymeds/azure-key-vault-agent/releases/download/v${AZURE_KEY_VAULT_AGENT_VERSION}/azure-key-vault-agent_${AZURE_KEY_VAULT_AGENT_VERSION}_linux_amd64.tar.gz -O hashistack/azure-key-vault-agent.tgz
tar -zxvf hashistack/azure-key-vault-agent.tgz -C hashistack/usr/bin/ azure-key-vault-agent

# Dmidecode
wget https://download.savannah.gnu.org/releases/dmidecode/dmidecode-${DMIDECODE_VERSION}.tar.xz -O hashistack/dmidecode.tar.xz
tar -xvf hashistack/dmidecode.tar.xz -C hashistack
cd hashistack/dmidecode-${DMIDECODE_VERSION}/
make dmidecode
cd $WORKDIR
mv hashistack/dmidecode-${DMIDECODE_VERSION}/dmidecode hashistack/usr/bin/
rm -rf hashistack/dmidecode-${DMIDECODE_VERSION}


rm hashistack/*.tgz
rm hashistack/*.tar.xz
rm hashistack/*.zip
RELOAD=1 ./bake.sh hashistack
rm -rf "hashistack"
sha256sum hashistack.raw | tee hashistack.raw.DIGESTS

echo "# Release $(date '+%Y-%m-%d %R')" > Release.md
echo "The release adds the following components:" >> Release.md
echo "* [HashiCorp Consul-template ${CONSUL_TEMPLATE_VERSION}](https://github.com/hashicorp/consul-template/releases/tag/v${CONSUL_TEMPLATE_VERSION})" >> Release.md
echo "* [HashiCorp Consul ${CONSUL_VERSION}](https://github.com/hashicorp/consul/releases/tag/v${CONSUL_VERSION})" >> Release.md
echo "* [HashiCorp Nomad ${NOMAD_VERSION}](https://github.com/hashicorp/nomad/releases/tag/v${NOMAD_VERSION})" >> Release.md
echo "* [HashiCorp Vault ${VAULT_VERSION}](https://github.com/hashicorp/vault/releases/tag/v${VAULT_VERSION})" >> Release.md
echo "* [CNI reference plugins ${CNI_PLUGINS_VERSION}](https://github.com/containernetworking/plugins/releases/tag/v${CNI_PLUGINS_VERSION})" >> Release.md
echo "* [Azure CNI plugins ${AZURE_CNI_PLUGINS_VERSION}](https://github.com/Azure/azure-container-networking/releases/tag/v${AZURE_CNI_PLUGINS_VERSION})" >> Release.md
echo "* [CoreDNS ${COREDNS_VERSION}](https://github.com/coredns/coredns/releases/tag/v${COREDNS_VERSION})" >> Release.md
echo "* [Grafana Loki ${LOKI_VERSION}](https://github.com/grafana/loki/releases/tag/v${LOKI_VERSION})" >> Release.md
echo "* [Azure Key Vault Agent ${AZURE_KEY_VAULT_AGENT_VERSION}](https://github.com/covermymeds/azure-key-vault-agent/releases/tag/v${AZURE_KEY_VAULT_AGENT_VERSION})" >> Release.md
echo "* [dmidecode ${DMIDECODE_VERSION}](http://download.savannah.gnu.org/releases/dmidecode/)" >> Release.md
echo "" >> Release.md
echo "Binaries inside of image are using following licenses:" >> Release.md
echo "* HashiCorp binaries, [Business Source License](https://www.hashicorp.com/en/bsl)" >> Release.md
echo "* CNI reference plugins, [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)" >> Release.md
echo "* Azure CNI plugins, [MIT](https://opensource.org/license/mit)" >> Release.md
echo "* CoreDNS, [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)" >> Release.md
echo "* Grafana binaries, [AGPLv3](https://grafana.com/licensing/)" >> Release.md
echo "* Azure Key Vault Agent, [The MIT License](https://opensource.org/license/mit)" >> Release.md
echo "* dmidecode, [GPL-2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)" >> Release.md
