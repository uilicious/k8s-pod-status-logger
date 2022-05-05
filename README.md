# k8s-pod-status-logger
Monitor kubernetes pods, and log their status changes




Docker Hub location: [`uilicious/k8-pod-status-logger`](https://hub.docker.com/r/uilicious/k8-pod-status-logger)

Automatically log kubernetes pods readiness.

This listens to kubernetes event stream, and  perodically scanning for pod status.

# ENV variable to configure the docker container

| Name                             | Default Value | Description                                                                                                                                           |
|----------------------------------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| NAMESPACE                        | -             | (Required) Namespace to limit the pod reaper to                                                                                                       |
| TARGETPOD                        | -             | Regex expression for matching POD, to apply the k8s-pod-completion-reaper to, if blank, matches all containers in the namespace                       |
| DEBUG                            | false         | If true, perform no action and logs it instead                                                                                                        |
| LOG_PROXY_HOOK_JSON              | false         | Delegate hook stdout/ stderr JSON logging to the hooks and act as a proxy that adds some extra fields.                                                |
| LOG_TYPE                         | text          | Logging formatter type: json, text or color.                                                                                                          |
| LOG_NO_TIME                      | true          | Disable timestamp logging if flag is present.                                                                                                         |
| LOG_LEVEL                        | info          | Log level, of shell-operator, use either "debug","info" or "error"                                                                                    |
| SHELL_OPERATOR_ENABLE            | true          | Enable the use of the main shell-operator workflow, which would react quicker in a "live" manner                                                      |

# Deployment

For the docker container to work, you will first need to setup the kubernetes RBAC.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-logger-svc-acc
  namespace: proj-namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-logger-role
  namespace: proj-namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list","delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-logger-role
  namespace: proj-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-logger-role
subjects:
  - kind: ServiceAccount
    name: pod-logger-svc-acc
    namespace: proj-namespace
```

Once the RBAC is succesfully setup, you can deploy the k8s-pod-status-logger operator.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-completion-logger
  namespace: proj-namespace
spec:
  selector:
    matchLabels:
      app: pod-completion-logger
  replicas: 1
  template:
    metadata:
      labels:
        app: pod-completion-logger
    spec:
      containers:
      - name: pod-completion-logger
        image: "uilicious/k8s-pod-completion-logger"
        env: 
          - name: "NAMESPACE"
            value: "proj-namespace"
```

# Misc: Development Notes

This is built on the shell-operator project
See: https://github.com/flant/shell-operator

Because the "object" definition is nearly impossible to find definitively online, if you want to understand each
object provided by ".[0].object", you may want to refer to either an existing cluster with `kubectl get pods -o json`
or alternatively [./notes/example-pod.yaml](./notes/example-pod.yaml).

This uses the APACHE license, to ensure its compatible with the shell-operator its built on.

# Regarding LOG_PROXY_HOOK_JSON
Doesn't seem to work ? See link below
https://github.com/flant/shell-operator/pull/383