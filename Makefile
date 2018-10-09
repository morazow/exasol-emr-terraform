#
# Makefile
#

all: init plan apply

init:
	terraform init

update:
	terraform get -update

plan: update
	terraform plan -var-file config.tfvars -out terraform.tfplan

apply:
	terraform apply -var-file config.tfvars

destroy:
	terraform plan -destroy -var-file config.tfvars -out terraform.tfplan
	terraform apply terraform.tfplan

exasol: init
	terraform plan -var-file config.tfvars -out exasol.tfplan -target module.exasol
	terraform apply exasol.tfplan

emr: init
	terraform plan -var-file config.tfvars -out emr.tfplan -target module.emr
	terraform apply emr.tfplan

clean:
	rm -rf terraform.tfplan exasol.tfplan emr.tfplan generated/


.PHONY: all init update plan apply destroy exasol emr clean
