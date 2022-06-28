# Google Cloud Run 
Cloud run manages the deployment of scalable containerized serverless applications applications [(Documentation)](https://cloud.google.com/run)
### gcp_cloudrun.yml
#### Prerequisites
* If creating a new project your must have an existing billing account ID to specify in the `billing_account` setting
* Cloud run retrieves images hosted in Artifact Registry (recommended)  or Container Registry.  
If creating a project, there must be an existing image that you have access to (public/global),
which is specified with the `image_uri` value in `gcp_clourun.yml`.
If using an existing project you can use an image hosted within the projects Container Registry or Artifact Registy,
provided you have the correct IAM permissions to access it.  

#### Cloud run specs
| Key                           |  Type  |                                     Required                                      | Description                                                                                                                                                                                                                                     |                           Default                           |
|:------------------------------|:------:|:---------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------:|
| `project_id`                  | string |                                       true                                        | The ID of the project to be used for the service                                                                                                                                                                                                |                            none                             |
| `location_id`                 | string |                                       true                                        | Location ID of the project used                                                                                                                                                                                                                 |                            none                             |
| `create_google_project`       |  bool  |                                       false                                       | Whether to create a new project for services                                                                                                                                                                                                    |                            false                            |
| `billing_account`             | string |                      true if `create_google_project` is true                      | The alphanumeric ID of the billing account this project belongs to.                                                                                                                                                                             |                            none                             |
| `create_artiface_registry`    |  bool  |                                       false                                       | whether to create an artifact registry repository                                                                                                                                                                                               |                            false                            |
| `name`                        | string |                                       true                                        | Name for Cloud Run Service, unique within cloud run region and cannot be updated                                                                                                                                                                |                            none                             |
| `image`                       | string |                                       true                                        | URI of where the image to be hosted is contained                                                                                                                                                                                                |                            none                             |
| `service_account_name`        | string |                                       false                                       | Service Account to be used the cloudrun service, defaults to the Compute Engine default service account                                                                                                                                         |                            none                             |
| `auth`                        |  bool  |                                       true                                        | Whether authentication is required to access service                                                                                                                                                                                            |                            false                            |
| `environment_vars`            |  map   |                                       false                                       | Any environment variables to include as for image. Key is the name of the variable and value is the string it represents                                                                                                                        |                            none                             |
| `iam`                         |  map   |                               true if `auth = true`                               | If authentication is required to access the service, include the iam block                                                                                                                                                                      |                            false                            |
| `iam.binding`                 |  map   | true if `replace_policy = true`, otherwise include if you want to update bindings | A block of roles and the members who will be assigned the roles. Keys should be the role, and the value for each key is the list of members assigned that role                                                                                  |                            none                             |
| `iam.bindings.[role].members` |  list  |                         true if `iam.bindings` has values                         | Members who will be assigned the role for the iam policy [details](#IAM-Settings)                                                                                                                                                               |                            none                             |
| `iam.replace_policy`          |  bool  |                                       false                                       | Sets IAM policy, replacing any existing policy attached                                                                                                                                                                                         |                            true                             |
| `iam.binding`                 |  bool  |                                       false                                       | Updates IAM policy to grant role to specified members                                                                                                                                                                                           |                            false                            |
| `iam.add_member`              |  map   |                                       false                                       | Adds a member who can can use a specified policy. If a binding policy exists the policy for `add_member` must be different. This must include the keys `role` and `member`, with `member` following the same format as an item in `iam.members` |                            none                             |
| `domain_name`                 | string |                                       false                                       | Custom domain name for service, domain must already exist                                                                                                                                                                                       |                            none                             |
| `traffic`                     |  list  |                                       false                                       | list of traffic allocation configs across revisions                                                                                                                                                                                             |               100% traffic to latest revision               |
| `traffic.-.percent`           |  map   |                            true if `traffic.-` exists                             | The percentage of traffic for revision, if `revision_name` is not specified latest revision is used                                                                                                                                             |                            none                             |
| `traffic.-.revision_name`     | string |                                       false                                       | The name of the revision the traffic should be allocated to                                                                                                                                                                                     | 'latest_revision' is set to true if this key is not present |

#### IAM Settings
##### Policy/Member Settings
Setting `replace_policy=true` defines the whole policy and will replace any policy attatched to the cloudrun service defined.
If this is an initial deployment with no previous IAM policies set, `replace_policy` should be set to `true` and all role bindings required should be defined in `bindings`.
If there is an existing policy which you want to update, not replace, set `replace_policy` to `false` and include one role in `bindings` to update.
Similarly, if there are existing role bindings, which you would like to add a member to, use `add_member` to assign that role to the member without replacing members already assigned to that role.  
> **NOTE:** Cannot have `add_member` if `replace_policy = true`, but can have `add_member` if both `replace_policy = false` and `bindings` has a value as long as they are not set for the same role.  

##### Member Definition
`iam.members` is a list of members in the form `{member_type}:{member}` which must be one of ([more info](https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html#member-members)):
* `"allUsers:"`
* `"allAuthenticatedUsers:"`
* `"user:{emailid}"`
* `"serviceAccount:{emailid}"`
* `"group:{emailid}"`
* `"domain:{domain}"`

More information can be found in the terraform [documentation](https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html).

## Secrets
Secrets can be attached to the cloudrun service by mounting as a volume (recommended). 
They can also be attached as environment variables if necessary, but this approach is not recommended due to inherent security risks.

To attach secrets to the cloudrun service they should be defined in a `secrets` block for the service definition in `gcp_cloudrun.yml`. 
To mount the secret as a volume specify the path to mount the secret with the `mount_location` attribute, and to add as an environment variable specify `env_name`.
If the secret is from a different project then cloudrun, that should be specified in `project` key.  
> **NOTE**: ensure the service account specified by `service_account_name` (or the default Compute engine service account), 
> has `roles/secretsManager.secretAccessor` for the relevant secrets
Example:
```yaml
components:
  specs:
    app1:
      name: "app1"
      ...
      secrets:
        secret_1:
          version: 1 #integer version value, defaults to "latest"
          mount_location: /mount/location/ #path to mount the secret volume to
          file_name: secret_file.txt #optional - file name of secret, defaults to secret name
          env_name: SECRET_ENV_1
          project: AnotherProject
        secret_2:
          version: 2
          env_name: SECRET_ENV_2
        secret_3:
          version: 1
          mount_location: "/mount/location/"
```

## Multiple Versions
By default the revision name for a Cloud Run deployment is auto-generated. 
To specify a revision name for the Cloud Run deployment, the key `components.specs.<app_name>.template.metadata.name` must be set, 
following the format of `<app_name>-<revision_id>`. 

The specs for multiple revisions can be managed:  

* `gcp_cloudrun.yml` will only contain the specifications for one revision of the Cloud Run service.  
* Updating the specifications with no revision name specified will deploy a new revision with the autogenerated name. 
  Updating specs with a revision name specified will update that revision.
* To run multiple versions, [terraform workspaces](https://www.terraform.io/docs/state/workspaces.html) should be used.  
  E.g. to deploy a new version of an application:
    1. Make a new branch using VCS and make revision and configuration changes to `gcp_cloudrun.yml` 
    2. Make a new terraform workspace by running: `terraform workspace new <version name>` 
    3. Import Cloud Run configuration to state file by running :
       * `terraform import 'module.mcp.google_cloud_run_service.self["<service>"]' <location_id>/<project-id>/<service>` 
       * `terraform import 'module.mcp.google_cloud_run_service_iam_policy.self[\"<service>\"]' projects/<project_id>/locations/<location>/services/<service>`
    4. Apply terraform changes, and commit changes to VCS

> **NOTE**: Running `terraform destroy` will destroy the whole Cloud Run Service, not just that revision 

### Traffic
By default, 100% of traffic is allocated to the latest revision. If managing multiple revisions traffic should be specified for each revision receiving traffic.
Revision specified must be an existing revision, and if no revision is specified, the traffic will be allocated to the latest revision.  

Traffic can either be allocated by specifying a `gcp_cloudrun_traffic.yml` file or by setting the environment variable `TF_VAR_gcp_cloudrun_traffic` to a map of traffic allocations.  
Traffic should be a mapping of `<service>;<revision_id>` to a percentage of traffic to send. 
Notes:
* Only one traffic allocation can be to the latest revision
* Traffic must always add up to 100%
* To use environment variable ensure `variable gcp_cloudrun_traffic {}` is in `main.tf` and the `module` block includes the line `gcp_cloudrun_traffic=var.gcp_cloudrun_traffic`

Example of traffic assignment using environment variables:
```shell
export TF_VAR_gcp_cloudrun_traffic='{"app1;v1" = 60, "app1;v2" = 40, "app1-service;v3" = 90, "app1-service;v4" = 10}'
```

Example of `gcp_cloudrun_traffic.yml`:
```yaml
app1;v1: 60
app1;v2: 40
app1-service;v3: 90
app1-service;v4: 10 
```

### Example Cloud Run Configuration
```yaml
project_id: <id>
location_id: "europe-west1"
create_google_project: true
create_artifact_registry: true

components:
  common: 
      
  specs:
    default:
      name: default
      domain: "default.company.com"
      metadata:
        
      template:
        metadata:
          name: default-2
        containers:
          image: <location>-docker.pkg.dev/project-id/repository/image
          environment_vars:
            'EG': 'something'
            'EG2': 'something-else'
      secrets:
        secret_1:
          version: 1
          mount_location: /etc/mounts/secret1
        secret_2:
          version: 2
          env_name: SECRET VALUE
      auth: true
      iam:
        replace_policy: true
        bindings:
          #Here 'viewer' is the role which the members are assigned to
          'viewer':
            members:
              - "user:user@example.com"
              - "allAuthenticatedUsers:"
          'admin':
            members:
              - "user:admin@example.com"
        add_member:
          role: 'admin'
          member: 'user: admin@example.com'
      domain_name: "domain.com"
      #Use hyphens to separate traffic configurations, making a list of configurations


```
