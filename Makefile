.PHONY: .EXPORT_ALL_VARIABLES all vpc cluster

.EXPORT_ALL_VARIABLES:
COMMAND=plan
WORKSPACE=

terraform-setup:
	TF_CLI_ARGS_init=" " WORKSPACE=$$(aws iam list-account-aliases --query AccountAliases[0] --output text) scripts/terraform.sh $@

all: vpc cluster

vpc:
	scripts/terraform.sh $@

cluster:
	scripts/terraform.sh $@