{{ define "dance.configure.pipelines" }}
- name: configure-pipelines
  image: "k8s.gcr.io/hyperkube:v1.12.1"
  command:
    - /bin/bash
    - -c
    - |
      set -o errexit
      set -o nounset
      set -o pipefail

      CRD="tektonconfigs"
      echo -n "Waiting for '$CRD' CRD: "
      while [ $(kubectl api-resources | grep -c "^$CRD ") = "0" ] ; do
        echo -n "."
        sleep 3
      done
      echo
      echo "OK"

      echo -n "Waiting for pipelines operator deployment: "
      until kubectl get "$CRD" config -n openshift-pipelines >/dev/null 2>&1; do
        echo -n "."
        sleep 3
      done
      echo
      echo "OK"

      # All actions must be idempotent
      echo "Updating the TektonConfig"
      kubectl patch "$CRD" config --type 'merge' --patch '{{ include "dance.includes.tektonconfig" . | indent 6 }}'
{{ end }}