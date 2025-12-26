{{- define "tp.name" -}}
tp-appscore
{{- end -}}

{{- define "tp.ns" -}}
{{ .Values.global.namespace | default .Release.Namespace }}
{{- end -}}

{{- define "tp.fullname" -}}
{{ include "tp.name" . }}
{{- end -}}
