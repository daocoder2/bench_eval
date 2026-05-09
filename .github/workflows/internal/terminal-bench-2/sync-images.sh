#!/usr/bin/env bash

set -euo pipefail

mapfile -t images < .github/workflows/internal/terminal-bench-2/images.txt

total=${#images[@]}
batch=${BATCH:?}
batch_size=$(( (total + 9) / 10 ))
start=$(( batch * batch_size ))
end=$(( start + batch_size ))
if (( end > total )); then end=$total; fi

echo "Batch ${batch}: syncing images ${start} to $((end - 1)) of ${total}"

for (( i=start; i<end; i++ )); do
  img="${images[$i]}"
  echo "[$((i+1))/${total}] Syncing ${img} ..."
  skopeo copy "docker://${img}" \
    # "docker://agent-registry.cn-beijing.cr.aliyuncs.com/docker-private/aiaas/${img}" \
    "docker://acr-maas-bj-registry.cn-beijing.cr.aliyuncs.com/maas/${img}" \
    --dest-creds="${DEST_CREDS}" || echo "WARN: failed to sync ${img}, continuing..."
done
