expected="${1}"
actual="${2}"

# They should have the same number of lines.
expected_lines=$(wc -l "${expected}" | cut -f1 -d' ')
actual_lines=$(wc -l "${actual}" | cut -f1 -d' ')

[[ "${expected_lines}" -eq "${actual_lines}" ]] && \
    # The header should always match.
    diff <(head -n1 "${expected}") <(head -n1 "${actual}") && \
    # The actual data rows may be out of order because of async, so sort them.
    diff <(sort "${expected}") <(sort "${actual}")
