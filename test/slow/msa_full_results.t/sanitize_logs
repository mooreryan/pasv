#!/bin/bash

sed -E 's/#[0-9]+/PID/g;s/[0-9]{2}:[0-9]{2}:[0-9]{2}/TIME/g;s/[0-9]{4}-[0-9]{2}-[0-9]{2}/DATE/g' "${1}" | sed -E 's/(.*) Working on.*/\1/' | sed -E 's/(.*) Running command.*/\1/'
