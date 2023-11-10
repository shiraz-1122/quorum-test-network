# Script to query blocks
rm -rf /hyperledger/caliper/workspace/caliper.log

# npx install --only=prod @hyperledger/caliper-cli@0.4.0

# npx caliper bind --caliper-bind-sut fabric:2.1.0

npx caliper launch manager --caliper-workspace ./caliper \
  --caliper-bind-sut besu:latest \
  --caliper-benchconfig /home/brunocosta/projetos/claudio/quorum-test-network/caliper/benchmarks/config.yaml \
  --caliper-networkconfig /home/brunocosta/projetos/claudio/quorum-test-network/caliper-network.json \
  --caliper-flow-only-test --caliper-besu-gateway-enabled \
  --caliper-besu-gateway-discovery \
  --caliper-besu-gateway-localhost false
  
