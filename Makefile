.PHONY: .EXPORT_ALL_VARIABLES all vpc cluster service-build service

.EXPORT_ALL_VARIABLES:
COMMAND=plan
WORKSPACE=dev

terraform-setup:
	BACKEND=local WORKSPACE=default scripts/terraform.sh $@

all: vpc cluster service-build service

vpc:
	scripts/terraform.sh $@

cluster:
	scripts/terraform.sh $@

service-build:
	scripts/terraform.sh $@

service:
	scripts/terraform.sh $@

destroy-all:
	make service COMMAND=destroy
	make service-build COMMAND=destroy
	make cluster COMMAND=destroy
	make vpc COMMAND=destroy