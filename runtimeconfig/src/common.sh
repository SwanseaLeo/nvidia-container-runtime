#! /bin/bash
# Copyright (c) 2018-2019, NVIDIA CORPORATION. All rights reserved.

# shellcheck disable=SC2015
[ -t 2 ] && readonly LOG_TTY=1 || readonly LOG_NO_TTY=1

if [ "${LOG_TTY-0}" -eq 1 ] && [ "$(tput colors)" -ge 15 ]; then
	readonly FMT_CLEAR=$(tput sgr0)
	readonly FMT_BOLD=$(tput bold)
	readonly FMT_RED=$(tput setaf 1)
	readonly FMT_YELLOW=$(tput setaf 3)
	readonly FMT_BLUE=$(tput setaf 12)
fi

log() {
	local -r level="$1"; shift
	local -r message="$*"

	local fmt_on="${FMT_CLEAR-}"
	local -r fmt_off="${FMT_CLEAR-}"

	case "${level}" in
		INFO)  fmt_on="${FMT_BLUE-}" ;;
		WARN)  fmt_on="${FMT_YELLOW-}" ;;
		ERROR) fmt_on="${FMT_RED-}" ;;
	esac
	printf "%s[%s]%s %b\n" "${fmt_on}" "${level}" "${fmt_off}" "${message}" >&2
}

with_retry() {
	local max_attempts="$1"
	local delay="$2"
	local count=0
	local rc
	shift 2

	while true; do
		set +e
		"$@"; rc="$?"
		set -e

		count="$((count+1))"

		if [[ "${rc}" -eq 0 ]]; then
			return 0
		fi

		if [[ "${max_attempts}" -le 0 ]] || [[ "${count}" -lt "${max_attempts}" ]]; then
			sleep "${delay}"
		else
			break
		fi
	done

	return 1
}
