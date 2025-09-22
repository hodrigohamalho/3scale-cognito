oc -n 3scale get pods -o json \
  | jq -r '
    .items[]
    | .metadata.name as $pod
    | .spec.containers[]
    | [$pod,
       .name,
       (.resources.requests.cpu // "none"),
       (.resources.requests.memory // "none"),
       (.resources.limits.cpu // "none"),
       (.resources.limits.memory // "none")]
    | @tsv' \
  | column -t