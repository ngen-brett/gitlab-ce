---
comments: false
description: "Learn how to use GitLab CI/CD, the GitLab built-in Continuous Integration, Continuous Deployment, and Continuous Delivery toolset to build, test, and deploy your application."
---

# GitLab Continuous Integration (GitLab CI/CD)

GitLab CI/CD is a tool built into GitLab for software development
through the [continuous methodologies](introduction/index.md#introduction-to-cicd-methodologies):

- Continuous Integration (CI)
- Continuous Delivery (CD)
- Continuous Deployment (CD)

## Overview

Continuous Integration works by pushing small code chunks to your
application's code base hosted in a Git repository, and, to every
push, run a pipeline of scripts to build, test, and validate the
code changes before merging them into the main branch.

Continuous Delivery and Deployment consist of a step further CI,
deploying automatically your application to production at every
push to the default branch of the repository.

These methodologies allow you to catch bugs and errors early in
the development cycle, ensuring that all the code deployed to
production complies with the code standards you established for
your app.

![GitLab CI/CD illustration]()

For a complete overview of these methodologies and GitLab CI/CD,
read the [Introduction to CI/CD with GitLab](introduction/index.md).

GitLab CI/CD is configured by a file called `.gitlab-ci.yml` placed
at the repository's root. The scripts set in this file are executed
by the [GitLab Runner](https://docs.gitlab.com/runner/).

## Getting started

To get started with GitLab CI/CD, we recommend you read through
the following documents:

- [How GitLab CI/CD works](introduction/index.md#how-gitlab-cicd-works).
- [GitLab CI/CD basic workflow](introduction/index.md#basic-cicd-workflow).
- [Step-by-step guide for writing `.gitlab-ci.yml` for the first time](../user/project/pages/getting_started_part_four.md).

You can also get started by using one of the
[`.gitlab-ci.yml` templates](https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/gitlab/ci/templates)
available through the UI. You can use them by creating a new file,
choosing a template that suits your application, and adjusting it
to your needs:

![Use a .gitlab-ci.yml template]()

For a broader overview, see the [CI/CD getting started](quick_start/README.md) guide.

Once you're familiar with how GitLab CI/CD works, see the
[`. gitlab-ci.yml` full reference](yaml/README.md)
for all the attributes you can set and use.

## GitLab CI/CD configuration

GitLab CI/CD supports numerous configuration options:

- [Pipelines](pipelines.md)
- [Environment variables](variables/README.md)
- [Environments](environments.md)
- [Job artifacts](../user/project/pipelines/job_artifacts.md)
- [Cache dependencies](caching/index.md)
- [Schedule pipelines](../user/project/pipelines/schedules.md)
- [Custom path for `.gitlab-ci.yml`](../user/project/pipelines/settings.md#custom-ci-config-path)
- [Git submodules for CI/CD](git_submodules.md)
- [SSH keys for CI/CD](ssh_keys/README.md)
- [Trigger pipelines through the API](triggers/README.md)
- [Integrate with Kubernetes clusters](../user/project/clusters/index.md)
- [GitLab Runner](https://docs.gitlab.com/runner/)
- [Optimize GitLab and Runner for large repositories](large_repositories/index.md)
- [`.gitlab-ci.yml` full reference](yaml/README.md)

Note that certain operations can only be performed according to the
[user](../user/permissions.md#gitlab-cicd-permissions) and [job](../user/permissions.md#job-permissions) permissions.

## GitLab CI/CD feature set

You can also use the vast GitLab CI/CD feature set to easily configure
it for specific purposes:

| Feature | Description |
|:--- |:--- |
| [Review Apps](review_apps/index.md) | Configure GitLab CI/CD to preview code changes. |
| [ChatOps](chatops/README.md) | Trigger CI jobs from chat, with results sent back to the channel. |
| [Deploy Boards](https://docs.gitlab.com/ee/user/project/deploy_boards.html) **[PREMIUM]** | Check the current health and status of each CI/CD environment running on Kubernetes. |
| [GitLab Pages](../user/project/pages/index.md) | Deploy static websites. |
| [Interactive Web Terminals](interactive_web_terminal/index.md) | Open an interactive web terminal to debug the running jobs. |
| [GitLab CI/CD for external repositories](https://docs.gitlab.com/ee/ci/ci_cd_for_external_repos/) **[PREMIUM]** | Get the benefits of GitLab CI/CD combined with repositories in GitHub and BitBucket Cloud. |
|[Container Scanning](https://docs.gitlab.com/ee/ci/examples/container_scanning.html) **[ULTIMATE]**| Check your Docker containers for known vulnerabilities. |
|[Dependency Scanning](https://docs.gitlab.com/ee/ci/examples/dependency_scanning.html) **[ULTIMATE]**| Analyze your dependencies for known vulnerabilities. |
|[JUnit tests](junit_test_reports.md)| Identify script failures directly on merge requests. |

### Advance use of GitLab CI/CD

Besides all the configuration options and features listed above,
GitLab CI/CD also supports:

| Feature | Description |
|:--- |:--- |
| [Auto DevOps](../topics/autodevops/index.md) | Easily set up your app's entire lifecycle. |
| [Auto Deploy](../topics/autodevops/index.md#auto-deploy) | Deploy your application to a production environment in a Kubernetes cluster. |
| [Canary Deployments](https://docs.gitlab.com/ee/user/project/canary_deployments.html) **[PREMIUM]** | Ship features to only a portion of your pods and let a percentage of your user base to visit the temporarily deployed feature. |
| [Feature Flags](https://docs.gitlab.com/ee/user/project/operations/feature_flags.html) **[PREMIUM]** | Deploy your features behind Feature Flags. |
| [GitLab Releases](../user/project/releases/index.md) | Add release notes to Git tags. |
| [Security Test reports](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate) **[ULTIMATE]** | Check for app vulnerabilities. |
| [Using Docker images](docker/using_docker_images.md) | Use GitLab and GitLab Runner with Docker to build and test applications. |
| [Building Docker images](docker/using_docker_build.md) | Maintain Docker-based projects using GitLab CI/CD. |
| [CI services](services/README.md)| Link Docker containers with your base image. |

## GitLab CI/CD examples

GitLab provides examples of configuring GitLab CI/CD in the form of:

- A collection of [examples and other resources](examples/README.md).
- Example projects that are available at the [`gitlab-examples`](https://gitlab.com/gitlab-examples) group. For example, see:
  - [`multi-project-pipelines`](https://gitlab.com/gitlab-examples/multi-project-pipelines) for examples of implementing multi-project pipelines.
  - [`review-apps-nginx`](https://gitlab.com/gitlab-examples/review-apps-nginx/) provides an example of using Review Apps.

## GitLab CI/CD administration **[CORE ONLY]**

As a GitLab administrator, you can change the default behavior
of GitLab CI/CD for:

- An [entire GitLab instance](../user/admin_area/settings/continuous_integration.md).
- Specific projects, using [pipelines settings](../user/project/pipelines/settings.md).

See also:

- [How to enable or disable GitLab CI/CD](enable_or_disable_ci.md).
- Other [CI administration settings](../administration/index.md#continuous-integration-settings).

## Why GitLab CI/CD?

The following articles explain reasons to use GitLab CI/CD
for your CI/CD infrastructure:

- [Why we chose GitLab CI for our CI/CD solution](https://about.gitlab.com/2016/10/17/gitlab-ci-oohlala/)
- [Building our web-app on GitLab CI](https://about.gitlab.com/2016/07/22/building-our-web-app-on-gitlab-ci/)

See also the [Why CI/CD?](https://docs.google.com/presentation/d/1OGgk2Tcxbpl7DJaIOzCX4Vqg3dlwfELC3u2jEeCBbDk) presentation.

## Breaking changes

As GitLab CI/CD has evolved, certain breaking changes have
been necessary. These are:

- [CI variables renaming for GitLab 9.0](variables/deprecated_variables.md#gitlab-90-renamed-variables). Read about the
  deprecated CI variables and what you should use for GitLab 9.0+.
- [New CI job permissions model](../user/project/new_ci_build_permissions_model.md).
  See what changed in GitLab 8.12 and how that affects your jobs.
  There's a new way to access your Git submodules and LFS objects in jobs.
