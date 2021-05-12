#!/bin/sh

set -eu
export LC_ALL=C

DOCKER=$(command -v docker 2>/dev/null)

IMAGE_REGISTRY=docker.io
IMAGE_NAMESPACE=hectormolinero
IMAGE_PROJECT=wine
IMAGE_TAG=latest
IMAGE_NAME=${IMAGE_REGISTRY:?}/${IMAGE_NAMESPACE:?}/${IMAGE_PROJECT:?}:${IMAGE_TAG:?}
CONTAINER_NAME=${IMAGE_PROJECT:?}

imageExists() { [ -n "$("${DOCKER:?}" images -q "${1:?}")" ]; }
containerExists() { "${DOCKER:?}" ps -af name="${1:?}" --format '{{.Names}}' | grep -Fxq "${1:?}"; }
containerIsRunning() { "${DOCKER:?}" ps -f name="${1:?}" --format '{{.Names}}' | grep -Fxq "${1:?}"; }

if ! imageExists "${IMAGE_NAME:?}" && ! imageExists "${IMAGE_NAME#docker.io/}"; then
	>&2 printf -- '%s\n' "\"${IMAGE_NAME:?}\" image doesn't exist!"
	exit 1
fi

if containerIsRunning "${CONTAINER_NAME:?}"; then
	printf -- '%s\n' "Stopping \"${CONTAINER_NAME:?}\" container..."
	"${DOCKER:?}" stop "${CONTAINER_NAME:?}" >/dev/null
fi

if containerExists "${CONTAINER_NAME:?}"; then
	printf -- '%s\n' "Removing \"${CONTAINER_NAME:?}\" container..."
	"${DOCKER:?}" rm "${CONTAINER_NAME:?}" >/dev/null
fi

CONTAINER_DEVICES=$(find /dev/ -mindepth 1 -maxdepth 1 \
	'(' -name 'tty*' -or -name 'dri' -or -name 'vga_arbiter' -or -name 'nvidia*' ')' \
	-exec printf -- '--device %s:%s\n' '{}' '{}' ';' \
)

printf -- '%s\n' "Creating \"${CONTAINER_NAME:?}\" container..."
# shellcheck disable=SC2086
"${DOCKER:?}" run \
	--name "${CONTAINER_NAME:?}" \
	--hostname "${CONTAINER_NAME:?}" \
	--detach \
	--shm-size 2g \
	--publish 3322:3322/tcp \
	--publish 3389:3389/tcp \
	--env ENABLE_XDUMMY=true \
	${CONTAINER_DEVICES?} \
	"${IMAGE_NAME:?}" "$@" >/dev/null

printf -- '%s\n\n' 'Done!'
exec "${DOCKER:?}" logs -f "${CONTAINER_NAME:?}"
