FROM flant/shell-operator:latest

# Adding alpine coreutils, this is required for some bash script utilities
# like the date command to work as expected
RUN apk add --update coreutils

# Add the pods-hook file, and entrypoint script
ADD hooks /hooks
ADD operator /operator
RUN chmod 755 /hooks/*.sh && chmod +x /hooks/*.sh && \
    chmod 755 /operator/*.sh && chmod +x /operator/*.sh

# Trigger the entrypoint script
ENTRYPOINT ["/sbin/tini", "--", "/operator/entrypoint.sh"]
CMD []

#
# Environment variables for usage
#
# This is required
#
ENV NAMESPACE=""

#
# Regex rule, for matching against pod names
# Which the termination action will be limited to
#
# This is required
#
ENV TARGETPOD=""

#
# LOG_LEVEL for the shell-operator, use either
# debug, info, error
#
# default="info"
#
ENV LOG_LEVEL="info"

#
# LOG_STATUS_CHANGE to trigger status change logging
# true or false
#
# default="true"
#
ENV LOG_STATUS_CHANGE="true"

