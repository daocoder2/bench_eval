mapfile -t images < .github/workflows/internal/swebench_multilingual/images.txt

# 过滤空行
images=($(printf '%s\n' "${images[@]}" | grep -v '^$'))
total=${#images[@]}
batch=${BATCH:?}
batch_count=8
batch_size=$(( (total + batch_count - 1) / batch_count ))
start=$(( batch * batch_size ))
end=$(( start + batch_size ))
(( end > total )) && end=$total

echo "Total: ${total}, Batch: ${batch}/${batch_count}, Processing: ${start}-$((end-1))"

success=0
failed=0
skipped=0

for (( i=start; i<end; i++ )); do
  img="${images[$i]}"
  target="acr-maas-bj-registry.cn-beijing.cr.aliyuncs.com/eval/${img}"
  
  echo -n "[$((i+1))/${total}] ${img} ... "
  
  # 检查目标镜像是否已存在
  if skopeo inspect "docker://${target}" --creds="${DEST_CREDS}" &>/dev/null; then
    echo "SKIP (already exists)"
    ((skipped++))
    continue
  fi
  
  # 同步镜像
  if skopeo copy "docker://${img}" "docker://${target}" --dest-creds="${DEST_CREDS}"; then
    echo "OK"
    ((success++))
  else
    echo "FAILED"
    ((failed++))
  fi
done

echo "Batch complete: ${success} succeeded, ${skipped} skipped, ${failed} failed"