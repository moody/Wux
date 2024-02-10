#!/bin/bash

files=$(find test -name '*.lua');
passed=0
failed=0

for file in $files; do
  echo "Running: $file"

  lua "$file"

  if [ $? -eq 0 ]; then
    ((passed+=1))
  else
    ((failed+=1))
  fi

  echo ""
done

echo "[Test Results]: $passed passed, $failed failed, $((passed + failed)) total"

if [ $failed -ne 0 ]; then
  exit 1
fi
