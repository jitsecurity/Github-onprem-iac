## Requirements

| Name                   | Type         | Description                      |
|------------------------|--------------|----------------------------------|
| Terraform version      | `>= v1.11.4` | Terraform version requirements   |
| Kubectl version        | `>= v1.32.3` | Kubectl version requirements     |
| Helm version           | `>= v3.17.3` | Helm version requirements        |

## Required Variables

Change these variables in the file `xmcyber.tfvars`

| Name                   | Type     | Description                      |
|------------------------|----------|----------------------------------|
| `cloudflare_zone_id`   | `string` | Cloudflare DNS zone ID (Take it from Cloudflare Zone page)          |
| `cloudflare_api_token` | `string` | Cloudflare API token (Generate it on Cloudflare)            |
| `cloudflare_email`     | `string` | Cloudflare account email         |
| `aws_region`           | `string` | AWS region (e.g., `us-east-1`)   |
| `initial_setup`        | `string` | Conditional flag for initial setup     |

---

## Optional Variables

| Name            | Type     | Default   | Description                            |
|-----------------|----------|-----------|----------------------------------------|
| `min_size`      | `number` | `1`       | Minimum number of worker nodes         |
| `max_size`      | `number` | `3`       | Maximum number of worker nodes         |
| `desired_size`  | `number` | `1`       | Desired number of worker nodes         |
| `environment`   | `string` | `"prod"`  | Tenant/environment label               |
| `instance_types`| `list`   | `["c6a.large","m5.large"]`  | Instance type for Karpenter              |
| `jit_name_prefix`      | `string` | `poc` | Prefix for AWS and Kubernetes resources |

---

## Helm values.yaml changes

| Name            | Type     | Default   | Description                            |
|-----------------|----------|-----------|----------------------------------------|
| `ingress.host`  | `string` | `domain`  | Your desired URL for the PR-Agent      |
| `tenant_id`     | `string` | `0000-0000` | Tenant id provided by JIT         |
| `lumigo.token`  | `string` | `change_me_please` | Tenant id provided by JIT         |

### Execution guide

```bash
terraform init                                                         # to initialize modules
terraform plan -var-file="xmcyber.tfvars"                              # to visualize planned changes
terraform apply -var-file="xmcyber.tfvars" -var="initial_setup=true"  # to apply changes to the cloud in init_mode
```

After `terraform` completes. Run it once again.

```bash
terraform apply -var-file="xmcyber.tfvars"  # to fully apply changes to the cloud
```

After completeing the `terraform` part continue with `helm`.

```bash
# Export your cloud credentials to run AWS CLI commands
# export AWS_PROFILE or other approach

# Update your local kubeconfig
aws eks update-kubeconfig --name poc

# Modify pr-agent/values.yaml on line 12
# Change tenant_id to your tenant provided by JIT
tenant_id: &tenant_id "your_tenant_id"

# Modify pr-agent/values.yaml on line 17
# Change lumigo.token to one provided by JIT
lumigo:
  token: "your_token"

# Modify pr-agent/values.yaml on line 47
# Change ingress.host to your desired hostname for the Web access
ingress:
  host: &host "your_hostname"

# Copy your own secrets.toml and configuration.toml to the terraform folder
# Make sure that both of these files are up-to-date (Verify that webhook_url field is defined)

# Install PR-Agent Helm chart
helm upgrade --install pr-agent ./pr-agent --set-file secrets.secretsToml=secret.toml --set-file configuration.configurationToml=configuration.toml -f ./pr-agent/values.yaml
```

After completing the following commands your service should be available on `https://<your_hostname>`
