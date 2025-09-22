#!/usr/bin/env bash
# arquivo: sum-usage-now.sh
# uso: ./sum-usage-now.sh ns1 ns2 ns3
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Uso: $0 <namespace1> [namespace2 ...]" >&2
  exit 1
fi

to_mcpu() { # aceita "250m" ou "0.25"
  local v="$1"
  if [[ "$v" == *m ]]; then
    echo "${v%m}"
  else
    # cores -> millicores
    awk -v c="$v" 'BEGIN{printf "%.0f", c*1000}'
  fi
}

to_Mi() { # aceita Ki, Mi, Gi, bytes
  local v="$1"
  if [[ "$v" == *Ki ]]; then
    awk -v x="${v%Ki}" 'BEGIN{printf "%.0f", x/1024}'
  elif [[ "$v" == *Mi ]]; then
    echo "${v%Mi}"
  elif [[ "$v" == *Gi ]]; then
    awk -v x="${v%Gi}" 'BEGIN{printf "%.0f", x*1024}'
  elif [[ "$v" == *Ti ]]; then
    awk -v x="${v%Ti}" 'BEGIN{printf "%.0f", x*1024*1024}'
  else
    # bytes -> Mi
    awk -v x="$v" 'BEGIN{printf "%.0f", x/1024/1024}'
  fi
}

printf "%-25s %15s %15s\n" "NAMESPACE" "CPU_USED(m)" "MEM_USED(Mi)"
printf "%s\n" "---------------------------------------------------------------"

total_cpu=0
total_mem=0

for ns in "$@"; do
  # oc top pods retorna: NAME  CPU(cores)  MEMORY(bytes)
  # --no-headers simplifica parse
  out=$(oc -n "$ns" adm top pods --no-headers 2>/dev/null || true)
  if [[ -z "$out" ]]; then
    printf "%-25s %15s %15s\n" "$ns" "-" "-"
    continue
  fi

  ns_cpu=0
  ns_mem=0

  # shellcheck disable=SC2001
  while read -r name cpu mem; do
    # cpu: pode vir "25m" ou "0.02"
    mcpu=$(to_mcpu "$cpu")
    # mem: pode vir "123Mi", "1Gi", etc (ou bytes)
    mi=$(to_Mi "$mem")
    ns_cpu=$((ns_cpu + mcpu))
    ns_mem=$((ns_mem + mi))
  done <<< "$out"

  total_cpu=$((total_cpu + ns_cpu))
  total_mem=$((total_mem + ns_mem))

  printf "%-25s %15d %15d\n" "$ns" "$ns_cpu" "$ns_mem"
done

printf "%s\n" "---------------------------------------------------------------"
printf "%-25s %15d %15d\n" "TOTAL" "$total_cpu" "$total_mem"