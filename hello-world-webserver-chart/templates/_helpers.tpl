{{/*
Generate common labels for resources.
*/}}
{{- define "webserver.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end }}
