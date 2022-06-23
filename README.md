# Multi-Cloud Platform Services

* [Mesoform Multi-Cloud Platform Services](#multi-cloud-platform-services)
  * [Background](#Background)
  * [MCCF](#MCCF)
* [This Repository](#this-repository)
  * [Adapter example usage](#adapter-example-usage)
* [Contributing](#Contributing)
* [License](#License)  

## Background
Mesoform Multi-Cloud Platform (MCP) is a set of tools and supporting infrastructure code which simplifies the deployment
of applications across multiple Cloud providers. The basis behind MCP is for platform engineers and application
engineers to be working with a single structure and configuration for deploying foundational infrastructure (like IAM
policies, Google App Engine or Kubernetes clusters) as would be used for deploying workloads to that infrastructure
(e.g. Containers/Pods).

Within this framework is a unified configuration language called Mesoform Multi-Cloud Configuration Format (or MCCF),
which is detailed below and provides a familiar YAML structure to what many of the native original services offer and
adapts it into HCL, the language of Hashicorp Terraform, and deploys it using Terraform, to gain the benefits (like
state management) which Terraform offers.


## MCCF
MCCF is a YAML-based configuration allowing for simple mapping of platform APIs for deploying applications. The adapters 
in this repository allow users to provide MCCF to configure these foundational resources as described [above](#this-repository).
Full details of MCCF can be found in the main [MCP repository](https://github.com/mesoform/Multi-Cloud-Platform).


# This Repository
This repository contains the codebase for application or service adapters which can be used to deploy MCP 
serverless/container workloads to a set of serverless/container platforms. Examples are

## Adapter example usage
### Google Cloud Platform 
* [Google App Engine](docs/GCP_APP_ENGINE.md)  
* [Google Cloud Run](docs/GCP_CLOUDRUN.md)  

An example configuration:
```yaml
create_google_project: true
project_id: &project_id protean-buffer-230514
organization_name: mesoform.com
folder_id: 320337270566
billing_account: "1234-5678-2345-7890"
location_id: "europe-west"
project_labels: &google_project_labels
  type: frontend
compliance:
  policies:
    url: https://github.com/mesoform/compliance-policies.git
    version: 1.0.0


components:
  common:
    entrypoint: java -cp "WEB-INF/lib/*:WEB-INF/classes/." io.ktor.server.jetty.EngineMain
    runtime: java11
    env: flex
    env_variables:
      GCP_ENV: true
      GCP_PROJECT_ID: *project_id
    system_properties:
      java.util.logging.config.file: WEB-INF/logging.properties
  specs:
    spec_version: v1.0.0
    experiences-search-sync:
      env: standard
    experiences-search:
      env: standard
    experiences-sidecar:
      env: standard
    default:
      root_dir: experiences-service
      runtime: java8
```

### Kubernetes
* [Kubernetes adapter documentation](docs/KUBERNETES.md)

An example configuration:
```yaml
components:
  specs:
    spec_version: v1.0.0
    app_1: 
      deployment:
        metadata:
          name: "mosquitto"
          namespace:
            labels:
            app: "mosquitto"
        spec:
          selector:
            match_labels:
              app: "mosquitto"
          template:
            metadata:
              labels:
                app: "mosquitto"
            spec:
              container:
                - name: "mosquitto"
                  image: "eclipse-mosquitto:1.6.2"
                  port:
                    - container_port: 1883
                  resources:
                    limits:
                      cpu: "0.5"
                      memory: "512Mi"
                    requests:
                      cpu: "250m"
                      memory: "50Mi"
      config_map:
        metadata:
          name: "mosquitto-config-file"
          labels:
            env: "test"
        data:
          'test': 'test'
        data_file:
          - ../resources/mosquitto.conf
        binary_data:
          bar: L3Jvb3QvMTAw
        binary_file:
          - ../resources/binary.bin
      secret:
        metadata:
          annotations:
            key1:
            key2:
          name: "mosquitto-secret-file"
          namespace:
          labels:
            env: "test"
        type: Opaque
        data:
          login: login
          password: password
          data_file:
          - ../resources/secret.file
```


# Contributing
Please read:

* [CONTRIBUTING.md](https://github.com/mesoform/documentation/blob/master/CONTRIBUTING.md)
* [CODE_OF_CONDUCT.md](https://github.com/mesoform/documentation/blob/master/CODE_OF_CONDUCT.md)


# License
This project is licensed under the [MPL 2.0](https://www.mozilla.org/en-US/MPL/2.0/FAQ/)
