aws sts get-caller-identity
echo 'alias tf="terraform"' >> ~/.zshrc
source ~/.zshrc
scp kafka-dp.yaml ubuntu@98.81.134.79:/home/ubuntu/

### CNPG
```
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.29/releases/cnpg-1.29.1.yaml
sudo curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | sudo sh -s -- -b /usr/local/bin
```
