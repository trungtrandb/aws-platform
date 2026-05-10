This document is a step-by-step guide for provisioning infrastructure and deploying workloads in this repository.

## 1) What this repository creates

This Terraform project provisions:

- 1 VPC with 3 public subnets
- 3 EC2 instances (Ubuntu 24.04 Spot) running K3s in server mode (HA)
- 1 Network Load Balancer exposing:
  - Kubernetes API: `:6443`
  - External Kafka brokers: `:9094`, `:9095`, `:9096`
  - Gateway HTTP entrypoint: `:80`

After infrastructure is ready, you deploy these Kubernetes manifests:

- `kafka-dp.yaml`: Kafka StatefulSet (KRaft), NodePort services, and Kafka UI
- `pgcluster.yaml`: CloudNativePG cluster
- `quakus-demo-dp.yaml`: Quakus demo application

## 2) Prerequisites

Install these tools on your local machine:

- AWS CLI (already configured via `aws configure`)
- Terraform >= 1.5
- `kubectl`
- SSH key pair (default public key path: `~/.ssh/id_rsa.pub`)

Quick checks:

```bash
aws sts get-caller-identity
terraform version
kubectl version --client
```

## 3) Important files

- `variables.tf`: shared variables
- `terraform.tfvars`: environment values (for example `k3s_token`, `admin_cidr`)
- `vpc.tf`, `ec2.tf`, `sg.tf`, `nlb.tf`: AWS infrastructure resources
- `outputs.tf`: endpoint outputs after apply
- `kafka-dp.yaml`, `pgcluster.yaml`, `quakus-demo-dp.yaml`: Kubernetes workloads

## 4) Step 1 - Configure Terraform variables

Update `terraform.tfvars`:

```hcl
k3s_token  = "replace-with-a-strong-random-token"
admin_cidr = "x.x.x.x/32"
```

Recommendations:

- Use a strong random value for `k3s_token`
- Do not use `0.0.0.0/0` for `admin_cidr` in production

If your SSH public key is not at the default path, update `public_key_path` in `variables.tf`.

## 5) Step 2 - Provision AWS infrastructure

Run inside this repository:

```bash
terraform init
terraform plan
terraform apply
```

Check outputs:

```bash
terraform output
```

Focus on:

- `ec2_public_ips`
- `nlb_dns_name`
- `kafka_bootstrap_endpoint`
- `quakus_demo_endpoint`

## 6) Step 3 - Replace `KAFKA_EXTERNAL_HOST` in `kafka-dp.yaml`

Before copying workloads to EC2, update `KAFKA_EXTERNAL_HOST` in `kafka-dp.yaml` with the `nlb_dns_name` value from Terraform output.

Example:

```yaml
- name: KAFKA_EXTERNAL_HOST
  value: "<nlb_dns_name>"
```

## 7) Step 4 - Copy workload files to EC2 by SCP

Copy workload manifests to each node (example loop):

```bash
scp kafka-dp.yaml pgcluster.yaml quakus-demo-dp.yaml "ubuntu@<first_ec2_public_ip>:/home/ubuntu/"
```

## 8) Step 5 - SSH to EC2 public IPs and run kubectl

You can run `kubectl` directly on a node after SSH.
Usually it is enough to run from the first server IP.

SSH to one node:

```bash
ssh ubuntu@<ec2_public_ip>
```

Run deployments on that node:

```bash
kubectl apply -f /home/ubuntu/pgcluster.yaml
kubectl apply -f /home/ubuntu/kafka-dp.yaml
kubectl apply -f /home/ubuntu/quakus-demo-dp.yaml
```

Verify:

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc -A
```

## 9) Service access

- Quakus demo: `http://<nlb_dns_name>/api`
- External Kafka bootstrap: `<nlb_dns_name>:9094` (also `:9095`, `:9096` for other brokers)
- Kafka UI: `http://<nlb_dns_name>/kafka-ui`

## 10) Cleanup

When you no longer need resources:

```bash
terraform destroy
```

## 11) Common issues

- Kafka external connectivity issue:
  - Verify `KAFKA_EXTERNAL_HOST` in `kafka-dp.yaml`
  - Verify SG/NLB listeners for `9094-9096` and NodePorts `30094-30096`
- Quakus demo pod troubleshooting:
  - Describe pod by label: `kubectl describe pod -l app=quakus-demo`
  - Follow pod logs by label: `kubectl logs -f -l app=quakus-demo --all-containers=true`
- Cannot SSH into EC2:
  - Verify `public_key_path` and matching private key on local machine

