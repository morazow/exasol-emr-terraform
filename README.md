# Exasol EMR Cluster Setup on AWS using Terraform

This is a Terraform project that creates Exasol and EMR clusters on Amazon AWS.

## Motivation

Exasol has a nice CloudFormation templates where you can build Exasol clusters.
Please have look at [SOL-605][sol-605]. However, if you want something to work
from command line and do not want to click around in AWS, then this project
might help you.

## Prerequisites

Several tools and accounts should be available before using the project.

### AWS Account

Create an AWS account if you do not have one already. You can [sign-up
here][aws-signup]. The account should have admin access and secret keys in order
to use the AWS Command Line tools.

### AWS CLI

Install aws command line interface. You can follow instructions provided at
[aws-cli][aws-cli] in order to install it.

### AWS CLI Profile

Create a credentials profile for `aws-cli` with access and secret keys of your
account.

```bash
$ aws configure --profile my-user-profile

AWS Access Key ID [None]: <Your AWS Account Access Key>
AWS Secret Access Key [None]: <Your AWS Account Secret Key>
Default region name [None]:
Default output format [None]:
```

We keep region and output formats empty.

You can manually edit credentials file, `~/.aws/credentials`, anytime if you
want to update it later.

### Install Terraform

You can follow the instructions [here][terraform-install].

## Usage

Copy the configuration file [`config.tfvars.example`](./config.tfvars.example)
to `config.tfvars` and modify the parameters inside it. Make sure you provide
the correct aws profile name and other variables.

An example configurations:

```hcl
profile                   = "exasol"
project                   = "mor-exa-test"
environment               = "staging"
exa_db_password           = "my-awesome-password"
exa_db_node_count         = "3"
exa_db_replication_factor = "1"
exa_db_standby_node       = "0"
emr_release_label         = "5.17.0"
emr_master_type           = "m4.xlarge"
emr_master_count          = "1"
emr_core_type             = "m4.2xlarge"
emr_core_count            = "3"
```

You can use Makefile command to create the clusters.

| Command      | Description
|:-------------|:-------------------------------------------------|
|`make`        |runs terraform `init`, `plan` and `apply`         |
|`make init`   |`terraform init`, run this if it is the first run |
|`make update` |`terraform update`                                |
|`make plan`   |`terraform plan`                                  |
|`make apply`  |`terraform apply`, create both clusters           |
|`make destroy`|`terraform destroy`, destroy everything           |
|`make exasol` |create only Exasol cluster                        |
|`make emr`    |create only EMR cluster                           |
|`make clean`  |remove plan or generated files                    |

## License

[The MIT License (MIT)](LICENSE.md)

[sol-605]: https://www.exasol.com/support/browse/SOL-605
[aws-signup]: https://aws.amazon.com/free
[aws-cli]: https://github.com/aws/aws-cli
[terraform-install]: https://www.terraform.io/downloads.html
