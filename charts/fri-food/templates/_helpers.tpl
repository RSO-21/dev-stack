{{- define "fri-food.name" -}}
fri-food
{{- end -}}

{{- define "fri-food.fullname" -}}
{{ .Release.Name }}
{{- end -}}

{{- define "fri-food.labels" -}}
helm.sh/chart: {{ include "fri-food.name" . }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "fri-food.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
