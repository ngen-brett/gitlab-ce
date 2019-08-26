# AWS Lambda + Gitlab

Build your AWS Lambda applications with Gitlab! 

Gitlab supports numerous ways deploy AWS Lambda applications in both Kubernetes Environments and also major cloud FAAS environments.

Currently we support:

- [Knative](../knative.md): Build Knative applications with Knative and gitlabktl on GKE
- [AWS Lambda](../aws.md): Create serverless applications via the Serverless Framework and gitlab-ci

## Examples



Knative extends Kubernetes to provide a set of middleware components that are useful to build modern, source-centric, container-based applications. Knative brings some significant benefits out of the box through its main components:

- [Nodejs](https://github.com/knative/serving): Request-driven compute that can scale to zero.
- [Python](https://github.com/knative/eventing): Management and delivery of events.

For more information on using Knative with gitlab, visit the [Knative docs](../knative.md).


## AWS Lambda + Gitlab

Gitlab allows users to easily deploy AWS Lambda functions and create rich serverless applications

For more information on deploying to AWS Lambda with gitlab, visit the [AWS Lambda docs](../aws.md).
