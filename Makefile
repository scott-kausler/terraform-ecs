.PHONY: .EXPORT_ALL_VARIABLES all vpc cluster

.EXPORT_ALL_VARIABLES:
COMMAND=plan
WORKSPACE=

terraform-setup:
	BACKEND=local WORKSPACE=default scripts/terraform.sh $@

all: vpc cluster

vpc:
	scripts/terraform.sh $@

cluster:
	scripts/terraform.sh $@