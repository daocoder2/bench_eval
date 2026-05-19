mapfile -t images < .github/workflows/internal/swebench_multilingual/images.txt

# 过滤空行
images=($(printf '%s\n' "${images[@]}" | grep -v '^$'))
total=${#images[@]}
batch=${BATCH:?}
batch_count=10
batch_size=$(( (total + batch_count - 1) / batch_count ))
start=$(( batch * batch_size ))
end=$(( start + batch_size ))
(( end > total )) && end=$total

echo "Total: ${total}, Batch: ${batch}/${batch_count}, Processing: ${start}-$((end-1))"

# 统计成功/失败
success=0
failed=0

for (( i=start; i<end; i++ )); do
  img="${images[$i]}"
  echo "[$((i+1))/${total}] Syncing ${img} ..."
  if skopeo copy "docker://${img}" \
    "docker://acr-maas-bj-registry.cn-beijing.cr.aliyuncs.com/maas/${img}" \
    --dest-creds="${DEST_CREDS}"; then
    ((success++))
  else
    echo "WARN: failed to sync ${img}, continuing..."
    ((failed++))
  fi
done

echo "Batch complete: ${success} succeeded, ${failed} failed"