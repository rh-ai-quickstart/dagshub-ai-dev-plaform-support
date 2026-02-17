{{/*
Expand the name of the chart.
*/}}
{{- define "dagshub-ai-dev-plaform-support.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "dagshub-ai-dev-plaform-support.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "dagshub-ai-dev-plaform-support.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.labels" -}}
helm.sh/chart: {{ include "dagshub-ai-dev-plaform-support.chart" . }}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dagshub-ai-dev-plaform-support.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dagshub-ai-dev-plaform-support.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dagshub-ai-dev-plaform-support.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image name helper
*/}}
{{- define "dagshub-ai-dev-plaform-support.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.global.imageRepository -}}
{{- $name := .name -}}
{{- $tag := .tag | default .Values.global.imageTag -}}
{{- printf "%s/%s/%s:%s" $registry $repository $name $tag -}}
{{- end }}

{{/*
API labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.api.labels" -}}
{{ include "dagshub-ai-dev-plaform-support.labels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
API selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.api.selectorLabels" -}}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
UI labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.ui.labels" -}}
{{ include "dagshub-ai-dev-plaform-support.labels" . }}
app.kubernetes.io/component: ui
{{- end }}

{{/*
UI selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.ui.selectorLabels" -}}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
app.kubernetes.io/component: ui
{{- end }}

{{/*
Database labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.database.labels" -}}
{{ include "dagshub-ai-dev-plaform-support.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Database selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.database.selectorLabels" -}}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Migration labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.migration.labels" -}}
{{ include "dagshub-ai-dev-plaform-support.labels" . }}
app.kubernetes.io/component: migration
{{- end }}

{{/*
Migration selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.migration.selectorLabels" -}}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
app.kubernetes.io/component: migration
{{- end }}

{{/*
MCP labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.mcp.labels" -}}
{{ include "dagshub-ai-dev-plaform-support.labels" . }}
app.kubernetes.io/component: mcp
{{- end }}

{{/*
MCP selector labels
*/}}
{{- define "dagshub-ai-dev-plaform-support.mcp.selectorLabels" -}}
{{ include "dagshub-ai-dev-plaform-support.selectorLabels" . }}
app.kubernetes.io/component: mcp
{{- end }}
