{{/*
Webserver full name: <release>-webserver
Truncated to 63 chars to satisfy DNS label limits.
*/}}
{{- define "webserver.fullname" -}}
{{- printf "%s-webserver" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}