# Gitlab instance administration

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/56883) in GitLab 12.2.

A project called `Gitlab Instance Administration` is present under a group called
`Gitlab Instance Administrators`. All administrators at the time of creation of the project
and group should be maintainers of the group. You can add new administrators as
members to the group in order to give them access to the project.

The project will be used for self-monitoring the GitLab instance.

## Adding a webhook to Prometheus to route alerts to GitLab

You can [add a webhook](../../../user/project/integrations/prometheus.md#external-prometheus-instances)
to your Prometheus config in order for GitLab to receive notifications of any alerts.

Once the webhook is setup, you can
[take action on incoming alerts](../../../user/project/integrations/prometheus.md#taking-action-on-incidents-ultimate).
