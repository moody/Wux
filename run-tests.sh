#!/bin/bash

set -e;

files=$(find test -name '*.lua');
passed=0
failed=0

for file in $files; do
  lua "$file" && ((passed+=1)) || ((failed+=1))
done

echo "[Test Results]: $passed passed, $failed failed, $((passed + failed)) total"

if [ $failed -ne 0 ]; then
  exit 1
fi
