#!/bin/bash

# Also need to sanitize tmpfile name: apple/pasv.tmp.be8bfe.queries.fasta

sed -E 's/#[0-9]+/PID/g;s/[0-9]{2}:[0-9]{2}:[0-9]{2}/TIME/g;s/[0-9]{4}-[0-9]{2}-[0-9]{2}/DATE/g' "${1}" | sed 's/pasv.tmp..*.queries.fasta/pasv.tmp.REDACTED.queries.fasta/'

