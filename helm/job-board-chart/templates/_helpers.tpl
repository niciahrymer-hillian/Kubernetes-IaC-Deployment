{{/*
Centralizes the name used for every resource's `metadata.name` and the
selector label that ties the Deployment to the Service — one place to
change the naming scheme instead of six.
*/}}
{{- define "job-board-chart.fullname" -}}
{{ .Release.Name }}-job-board
{{- end -}}
