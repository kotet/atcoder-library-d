#!/bin/bash

output_file="snippets.d"

echo "removing" ${output_file} "..."
rm -f ${output_file}

append_file() {
    (
        prefix=$(mktemp --suffix="$(echo ${1} | sed 's/\//\-/g')")
        result=$(csplit -f "${prefix}" -s "${1}" /---/)
        resultnum=$(printf "%s\n" "${result}" | wc -l)
        i=1
        while [ "${i}" -le ${resultnum} ]; do
            cat "${prefix}$(printf "%02d" ${i})" >>${output_file}
            i=$((i + 1))
        done
        i=0
        while [ "${i}" -le ${resultnum} ]; do
            rm "${prefix}$(printf "%02d" ${i})"
            i=$((i + 1))
        done
    )
}

for file in $(find source/acl -type f -name '*.d'); do
    echo "concatnating" ${file} "..."
    append_file ${file}
done
