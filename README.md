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

In order to install Terraform, you can follow the instructions from
[here][terraform-install].

## Usage

Please follow these steps for quick start usage.

### Configuration Params

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

### User Public SSH Keys

Additionally you can add public ssh keys so that you can ssh to EMR master node
without providing private pem file.

Edit file [`bootstrap_user_keys.sh`](./bootstrap_user_keys.sh) as follows:

```bash
#!/bin/bash

cat <<EOT >> ~/.ssh/authorized_keys
ssh-rsa SSH_PUBLIC_KEY <username>
#
# ADD MORE HERE
#
EOT
```

Then you can easily ssh into emr master node:

```bash
ssh hadoop@$(terraform output out-emr-master-dns)
```

Similarly with socks proxy enabled:

```bash
ssh -D 8157 hadoop@$(terraform output out-emr-master-dns)
```

### Makefile

You can use Makefile command to create the clusters.

| Command              | Description
|:---------------------|:-------------------------------------------------|
|`make`                |runs terraform `init`, `plan` and `apply`         |
|`make init`           |`terraform init`, run this if it is the first run |
|`make update`         |`terraform update`                                |
|`make plan`           |`terraform plan`                                  |
|`make apply`          |`terraform apply`, create both clusters           |
|`make destroy`        |`terraform destroy`, destroy everything           |
|`make exasol`         |create only Exasol cluster                        |
|`make emr`            |create only EMR cluster                           |
|`make clean`          |remove plan or generated files                    |
|`make run-etl-import` |runs etl loader scripts to populate Exasol tables |

## Manual Steps

This is not fully automated yet, there are still some manual steps you need to
follow. Some of them are:

- Open Exasol BucketFS http & https ports
- Create an Exasol bucket
- Upload jars to Exasol buckets
- Run ETL loader scripts to populate Exasol tables `make run-etl-import`;
  however, for this to work ETL jars should be uploaded to bucket
  `/buckets/bfsdefault/bucket1/`.

## License

[The MIT License (MIT)](LICENSE.md)

[sol-605]: https://www.exasol.com/support/browse/SOL-605
[aws-signup]: https://aws.amazon.com/free
[aws-cli]: https://github.com/aws/aws-cli
[terraform-install]: https://www.terraform.io/downloads.html
