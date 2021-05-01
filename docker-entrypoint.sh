#!/bin/bash

if [ "$1" = "start" ]; then
	/sslh -f ${SSLH_OPTS}
else
	exec "$@"
fi
