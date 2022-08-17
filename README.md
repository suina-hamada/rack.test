## Helpful Links and References

* [Onboarding Console Managed Environments with Terraform](https://one.rackspace.com/pages/viewpage.action?spaceKey=maws&title=Onboarding+Console+Managed+Environments+with+Terraform)
* [Phoenix - Terraform Style Guide (FAWS Best Practice)](https://one.rackspace.com/pages/viewpage.action?pageId=558926488&searchId=7FKBFETJQ)

### Helpful Reference Examples

Since most of the base module will be referenced as input values to the other modules, here are some common examples of referencing output values from the base layer:

**_Note_: Make sure your main.tf has appropriate terraform_remote_state data blocks defined first.**

```
internal_zone_id    = data.terraform_remote_state.base.outputs.r53_internal_zone
internal_zone_name  = data.terraform_remote_state.base.outputs.r53_internal_name
notification_topic  = data.terraform_remote_state.base.outputs.sns_topic_arn
security_group_list = [data.terraform_remote_state.data.outputs.sg_rds_id]
subnets             = data.terraform_remote_state.base.outputs.private_subnets
vpc_id              = data.terraform_remote_state.base.outputs.vpc_id
```

### Caveats

1. If the state file is not referenced for the other layers, you will not be able to consume outputs to populate the input of the next layer. This is important if you reference anything from the data later in the compute layer.
1. The `backend` block in the `terraform` object that defines where the state file lives has to be hard coded and does not work with [expressions](https://www.terraform.io/docs/configuration/expressions.html) or [functions](https://www.terraform.io/docs/configuration/functions.html). Be sure to update the environment and layer name in the `key` or you could damage resources you have already created.
1. Some resources/modules require security groups, IAM, or tags to be passed in using different formats to those you would expect. An example would be a single string vs a list of strings for security groups, or a map of tags vs a list of maps containing key/value/propagate_at_launch keys for the additional_tags for AutoScaling.
1. It tends to be easier to only have variables for items that are commonly referenced, things like: account numbers, regions, CIDRs, environment, etc. Things that are resource specific tend to be easier to hard code in the module reference for that resource.

### Repository Structure

The below is a representation of a Console managed customer. Although there are some differences between console and MIAC, the 000base/100data/200compute pattern is something practiced in MIAC as well.

```
<ddi-customer-name>
├── .gitignore
├── 99999999999
│   ├── .terraform-version
│   ├── docs
│   │   └── .gitkeep
│   └── layers
│       ├── Development
│       │   ├── 000base
│       │   │   ├── variables.tf
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   ├── README.md
│       │   │   └── terraform.tfvars
│       │   ├── 100data
│       │   │   ├── variables.tf
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   ├── README.md
│       │   │   └── terraform.tfvars
│       │   └── 200compute
│       │       ├── variables.tf
│       │       ├── main.tf
│       │       ├── outputs.tf
│       │       ├── README.md
│       │       └── terraform.tfvars
│       └── _main
│           ├── variables.tf
│           ├── .gitignore
│           ├── main.tf
│           ├── outputs.tf
│           ├── README.md
│           └── terraform.tfvars
└── README.md
```
