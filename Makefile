#
# Makefile
#

all: init plan apply

init:
	terraform init

plan:
	terraform get -update
	terraform plan -var-file config.tfvars -out terraform.tfplan

apply:
	terraform apply -var-file config.tfvars

destroy:
	terraform plan -destroy -var-file config.tfvars -out terraform.tfplan
	terraform apply terraform.tfplan

.PHONY: all init plan apply destroy
