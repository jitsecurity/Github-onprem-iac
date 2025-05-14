{{/*
Expand the name of the chart.
*/}}
{{- define "pr-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "pr-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Get the proper AWS account ID based on environment
*/}}
{{- define "pr-agent.accountId" -}}
{{- $accountId := .Values.image.accountId }}
{{- if eq $accountId "" }}
{{- $accountId = index .Values.environment.accountIds .Values.environment.name }}
{{- end }}
{{- printf "%s" $accountId }}
{{- end }}

{{/*
Create the ECR repository URL
*/}}
{{- define "pr-agent.ecrRepository" -}}
{{- $accountId := include "pr-agent.accountId" . }}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s:%s" $accountId .Values.aws.region .Values.image.repository .Values.image.tag }}
{{- end }}

{{/*
Get the namespace for resources
*/}}
{{- define "pr-agent.namespace" -}}
{{- if not .Values.tenant_id -}}
{{- fail "Error: tenant_id is required but not set" -}}
{{- end -}}
{{- printf "%s" .Values.tenant_id -}}
{{- end }}

{{/*
Render the configuration.toml file
*/}}
{{- define "pr-agent.configuration" -}}
{{- $configuration := "" -}}
{{- if .Values.onprem }}
  {{- $original := .Values.configuration.configurationToml -}}
  {{- $pattern := `(?m)^webhook_url\s*=\s*""` -}}
  {{- $replacement := printf "webhook_url = \"%s\"" .Values.ingress.host -}}
  {{- $configuration = regexReplaceAll $pattern $original $replacement -}}
{{- else }}
  {{- $configuration = .Values.configuration.configurationToml -}}
{{- end }}
{{- printf "%s" $configuration }}
{{- end }}

{{/*
Get the IAM role ARN for ECR access
*/}}
{{- define "pr-agent.iamRoleArn" -}}
{{- if .Values.aws.iam.roleArn -}}
{{- .Values.aws.iam.roleArn -}}
{{- else -}}
{{- $accountId := include "pr-agent.accountId" . -}}
{{- printf "arn:aws:iam::%s:role/PR-Agent-ECR-Role" $accountId -}}
{{- end -}}
{{- end }}

{{/*
Get the ingress host based on tenant_id and environment domain
*/}}
{{- define "pr-agent.ingressHost" -}}
{{- if not .Values.tenant_id -}}
{{- fail "Error: tenant_id is required but not set" -}}
{{- end -}}
{{- $domain := "" -}}
{{- if .Values.on_prem -}}
{{- $domain = .Values.ingress.host -}}
{{- printf "%s" $domain -}}
{{- else -}}
{{- $domain := index .Values.environment.domains .Values.environment.name -}}
{{- printf "tenant-webhooks-%s.%s" .Values.tenant_id $domain -}}
{{- end -}}
{{- end }}

{{/*
Get the gateway host based on tenant_id and environment
*/}}
{{- define "pr-agent.gatewayHost" -}}
{{- if not .Values.tenant_id -}}
{{- fail "Error: tenant_id is required but not set" -}}
{{- end -}}
{{- if eq .Values.environment.name "prod" -}}
{{- printf "tenant-webhooks-%s.jit-agent.jit.io" .Values.tenant_id -}}
{{- else if eq .Values.environment.name "staging" -}}
{{- printf "tenant-webhooks-%s.jit-agent.%s.jit.io" .Values.tenant_id .Values.environment.name -}}
{{- else -}}
{{- printf "tenant-webhooks-%s.jit-agent.%s.jitdev.io" .Values.tenant_id .Values.environment.name -}}
{{- end -}}
{{- end }} 