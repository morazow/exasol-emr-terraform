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
	terraform apply -auto-approve -var-file config.tfvars

destroy:
	terraform plan -destroy -var-file config.tfvars -out terraform.tfplan
	terraform apply terraform.tfplan

exasol: init update
	terraform plan -var-file config.tfvars -out exasol.tfplan -target module.exasol
	terraform apply exasol.tfplan

emr: init update
	terraform plan -var-file config.tfvars -out emr.tfplan -target module.emr
	terraform apply emr.tfplan

run-hive:
	@echo "HIVE_START = $$(date '+%H:%M:%S')"
	ssh hadoop@$$(terraform output out-emr-master-dns) 'hive -f /home/hadoop/scripts/retail.sql'
	@echo "HIVE_END = $$(date '+%H:%M:%S')"

run-etl-import:
	@echo "ETL_START = $$(date '+%H:%M:%S')"
	ssh hadoop@$$(terraform output out-emr-master-dns) '/home/hadoop/scripts/exa_etl_import.sh'
	@echo "ETL_END = $$(date '+%H:%M:%S')"

clean:
	rm -rf terraform.tfplan terraform.tfstate* exasol.tfplan emr.tfplan generated/ rendered/


.PHONY: all init update plan apply destroy exasol emr clean
