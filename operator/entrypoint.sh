#!/bin/bash

#
# ENV variables safety check
#
if [ -z "$NAMESPACE" ]
then
      echo "# [CRITICAL-ISSUE] Missing required 'NAMESPACE' environment variable"
      exit 1
fi
if [ -z "$TARGETPOD" ]
then
      echo "# [WARNING] Missing required 'TARGETPOD' environment variable - this will match against all pods in the namespace"
fi

# Wait for everything to finish, before terminating the process
wait
