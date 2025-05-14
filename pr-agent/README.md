# PR Agent Helm Chart for Tenant d93781f6-6de2-4834-ba6f-f4c9d9254d01

This package contains a Helm chart for deploying PR Agent to Kubernetes.

## Deployment Instructions

To deploy this chart, run:

```bash
helm install pr-agent .   --set tenant_id=d93781f6-6de2-4834-ba6f-f4c9d9254d01   --set-file secrets.secretsToml=./secrets.toml   --set-file configuration.configurationToml=./configuration.toml   --set lumigo.token=t_b039e560bf3243aaa3eca   -f ./values.yaml
```
