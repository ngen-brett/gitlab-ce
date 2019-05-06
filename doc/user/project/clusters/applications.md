# GitLab Managed Apps

GitLab provides **GitLab Managed Apps**, a one-click install for various applications which can
be added directly to your configured cluster. These applications are
needed for [Review Apps](../../../ci/review_apps/index.md) and
[deployments](../../../ci/environments.md) when using [Auto DevOps](../../../topics/autodevops/index.md).
You can install them after you
[create a cluster](index.md#adding-and-creating-a-new-gke-cluster-via-gitlab).

Applications managed by GitLab will be installed onto the `gitlab-managed-apps` namespace. This differrent
from the namespace used for project deployments. It is only created once and its name is not configurable.

To see a list of available applications to install:

1. Navigate to your project's **Operations > Kubernetes**.
1. Select your cluster.

Install Helm first as it's used to install other applications.

NOTE: **Note:**
As of GitLab 11.6, Helm will be upgraded to the latest version supported
by GitLab before installing any of the applications.

| Application | GitLab version | Description | Helm Chart |
| ----------- | :------------: | ----------- | --------------- |
| [Helm](https://docs.helm.sh/) | 10.2+ | Helm is a package manager for Kubernetes and is required to install all the other applications. It is installed in its own pod inside the cluster which can run the `helm` CLI in a safe environment. | n/a |
| [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) | 10.2+ | Ingress can provide load balancing, SSL termination, and name-based virtual hosting. It acts as a web proxy for your applications and is useful if you want to use [Auto DevOps] or deploy your own web apps. | [stable/nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) |
| [Cert-Manager](https://docs.cert-manager.io/en/latest/) | 11.6+ | Cert-Manager is a native Kubernetes certificate management controller that helps with issuing certificates. Installing Cert-Manager on your cluster will issue a certificate by [Let's Encrypt](https://letsencrypt.org/) and ensure that certificates are valid and up-to-date. | [stable/cert-manager](https://github.com/helm/charts/tree/master/stable/cert-manager) |
| [Prometheus](https://prometheus.io/docs/introduction/overview/) | 10.4+ | Prometheus is an open-source monitoring and alerting system useful to supervise your deployed applications. | [stable/prometheus](https://github.com/helm/charts/tree/master/stable/prometheus) |
| [GitLab Runner](https://docs.gitlab.com/runner/) | 10.6+ | GitLab Runner is the open source project that is used to run your jobs and send the results back to GitLab. It is used in conjunction with [GitLab CI/CD](../../../ci/README.md), the open-source continuous integration service included with GitLab that coordinates the jobs. When installing the GitLab Runner via the applications, it will run in **privileged mode** by default. Make sure you read the [security implications](index.md/#security-implications) before doing so. | [runner/gitlab-runner](https://gitlab.com/charts/gitlab-runner) |
| [JupyterHub](http://jupyter.org/) | 11.0+ | [JupyterHub](https://jupyterhub.readthedocs.io/en/stable/) is a multi-user service for managing notebooks across a team. [Jupyter Notebooks](https://jupyter-notebook.readthedocs.io/en/latest/) provide a web-based interactive programming environment used for data analysis, visualization, and machine learning. We use a [custom Jupyter image](https://gitlab.com/gitlab-org/jupyterhub-user-image/blob/master/Dockerfile) that installs additional useful packages on top of the base Jupyter. Authentication will be enabled only for [project members](../members/index.md) with [Developer or higher](../../permissions.md) access to the project. You will also see ready-to-use DevOps Runbooks built with Nurtch's [Rubix library](https://github.com/amit1rrr/rubix). More information on creating executable runbooks can be found in [our Nurtch documentation](runbooks/index.md#nurtch-executable-runbooks). Note that Ingress must be installed and have an IP address assigned before JupyterHub can be installed. | [jupyter/jupyterhub](https://jupyterhub.github.io/helm-chart/) |
| [Knative](https://cloud.google.com/knative) | 11.5+ | Knative provides a platform to create, deploy, and manage serverless workloads from a Kubernetes cluster. It is used in conjunction with, and includes [Istio](https://istio.io) to provide an external IP address for all programs hosted by Knative. You will be prompted to enter a wildcard domain where your applications will be exposed. Configure your DNS server to use the external IP address for that domain. For any application created and installed, they will be accessible as `<program_name>.<kubernetes_namespace>.<domain_name>`. This will require your kubernetes cluster to have [RBAC enabled](index.md#role-based-access-control-rbac). | [knative/knative](https://storage.googleapis.com/triggermesh-charts)

With the exception of Knative, the applications will be installed in a dedicated
namespace called `gitlab-managed-apps`.

CAUTION: **Caution:**
If you have an existing Kubernetes cluster with Helm already installed,
you should be careful as GitLab cannot detect it. In this case, installing
Helm via the applications will result in the cluster having it twice, which
can lead to confusion during deployments.

### Upgrading applications

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/24789)
in GitLab 11.8.

Users can perform a one-click upgrade for the GitLab Runner application,
when there is an upgrade available.

To upgrade the GitLab Runner application:

1. Navigate to your project's **Operations > Kubernetes**.
1. Select your cluster.
1. Click the **Upgrade** button for the Runnner application.

The **Upgrade** button will not be shown if there is no upgrade
available.

NOTE: **Note:**
Upgrades will reset values back to the values built into the `runner`
chart plus the values set by
[`values.yaml`](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/vendor/runner/values.yaml)

### Uninstalling applications

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/60665) in
> GitLab 11.11.

The applications below can be uninstalled.

| Application | GitLab version | Notes |
| ----------- | -------------- | ----- |
| Prometheus  | 11.11+         | All data will be deleted and cannot be restored. |

To uninstall an application:

1. Navigate to your project's **Operations > Kubernetes**.
1. Select your cluster.
1. Click the **Uninstall** button for the application.

Support for uninstalling all applications will be progressively
introduced (see [related
epic](https://gitlab.com/groups/gitlab-org/-/epics/1201)).

### Troubleshooting applications

Applications can fail with the following error:

```text
Error: remote error: tls: bad certificate
```

To avoid installation errors:

- Before starting the installation of applications, make sure that time is synchronized
  between your GitLab server and your Kubernetes cluster.
- Ensure certificates are not out of sync.  When installing applications, GitLab expects a new cluster with no previous installation of Helm.

  You can confirm that the certificates match via `kubectl`:

  ```sh
  kubectl get configmaps/values-content-configuration-ingress -n gitlab-managed-apps -o \
  "jsonpath={.data['cert\.pem']}" | base64 -d > a.pem
  kubectl get secrets/tiller-secret -n gitlab-managed-apps -o "jsonpath={.data['ca\.crt']}" | base64 -d > b.pem
  diff a.pem b.pem
  ```

