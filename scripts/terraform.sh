#!/usr/bin/env bash
set -eou pipefail

MODULE=$1

#Set up environment specific variables
set -a
. environments/default.sh
[ -f environments/${WORKSPACE}.sh ] && . environments/${WORKSPACE}.sh
set +a

export TF_CLI_ARGS_apply=${TF_CLI_ARGS_apply:-"-auto-approve"}
export TF_CLI_ARGS_destroy=${TF_CLI_ARGS_destroy:-"-auto-approve"}

export TF_VAR_workspace=$WORKSPACE
export TF_VAR_module=$MODULE

#Reuse some common terraform code, such as variables
cp terraform/common/common-variables.tf terraform/${MODULE}/common-variables.built.tf

if [ "${BACKEND:-s3}" == "s3" ]; then
  cp terraform/common/s3-backend.tf terraform/${MODULE}
  BACKEND_BUCKET=$(cd terraform/terraform-setup && terraform output -raw tf_state)
  BACKEND_KEY=${MODULE}/$WORKSPACE

  echo "BACKEND_BUCKET=$BACKEND_BUCKET"
  echo "BACKEND_KEY=$BACKEND_KEY"
  echo "AWS_REGION=$AWS_REGION"

  export TF_CLI_ARGS_init="${TF_CLI_ARGS_init:-} -backend-config=\"bucket=${BACKEND_BUCKET}\""
  export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config=\"key=${BACKEND_KEY}\""
  export TF_CLI_ARGS_init="$TF_CLI_ARGS_init -backend-config=\"region=${AWS_REGION}\""
fi

pushd terraform/$MODULE
terraform fmt
terraform init
terraform workspace new $WORKSPACE || terraform workspace select $WORKSPACE
terraform "$COMMAND"
popd > /dev/null