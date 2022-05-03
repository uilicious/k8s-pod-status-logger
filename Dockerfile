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
ENV NAMESPACE="example-monitor-events"

#
# Regex rule, for matching against pod names
# Which the termination action will be limited to
#
# This is required
#
ENV TARGETPOD=""

#
# Delegate hook stdout/ stderr JSON logging to the hooks
# and act as a proxy that adds some extra fields before just printing the output.
# NOTE: It ignores LOG_TYPE for the output of the hooks; 
# expects JSON lines to stdout/ stderr from the hooks
#
# Doesn't seem to work ? See link below
# https://github.com/flant/shell-operator/pull/383
#
ENV LOG_PROXY_HOOK_JSON="false"

#
#Logging formatter type: json, text or color.
#
# default is json
ENV LOG_TYPE="json"

#
# LOG_LEVEL for the shell-operator, use either
# debug, info, error
#
# default="info"
#
ENV LOG_LEVEL="info"

#
# Disable timestamp logging if flag is present.
# Useful when output is redirected to logging system that already adds timestamps.
#
# default = "false"
#
ENV LOG_NO_TIME="false"

#
# Enable the use of the main shell-operator workflow
# This helps react to event quicker in a "live" manner for pod completion events, 
# however seems to sometimes "miss" event based on our observations in the field.
#
# default="true"
#
ENV SHELL_OPERATOR_ENABLE="true"