#!/usr/bin/env bash
set -eou pipefail

MODULE=$1

export TF_CLI_ARGS_apply=${TF_CLI_ARGS_apply:-"-auto-approve"}
export TF_CLI_ARGS_destroy=${TF_CLI_ARGS_destroy:-"-auto-approve"}
export TF_CLI_ARGS_init=${TF_CLI_ARGS_init:-"-backend-config=\"key=infra-cluster/terraform/${MODULE}/${WORKSPACE}\""}

export TF_VAR_workspace=$WORKSPACE
export TF_VAR_module=$MODULE

#Reuse some common terraform code, such as variables
pushd terraform/common
for filename in *.tf; do
  cp $filename "../$MODULE/${filename%.tf}.built.tf"
done
popd

#Set up environment specific variables
set -a
. environments/default.sh
[ -f environments/${WORKSPACE}.sh ] && . environments/${WORKSPACE}.sh
set +a

pushd terraform/$MODULE
terraform fmt
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE || true
terraform init
terraform "$COMMAND"
popd > /dev/null