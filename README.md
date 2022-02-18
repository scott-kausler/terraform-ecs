# terraform-ecs

# Install and Setup
AWS CLI V2
Terraform
Docker

Use `aws configure` to set up your AWS creds

# Usage
Run `make all COMMAND=apply`

Wait for all the terraform targets to complete and you will see a URL output. Browse to that URL to see the sample nodejs app.

USE `WORKSPACE=<workspace>` to deploy in a different workspace. Default is `dev`.

The default command is `plan`. You can pass in in any other terraform command.

See `Makefile` for additional targets.

# About
This is a sample node js app deployed in AWS ECS/Fargate. Separated into multiple logically separated terraform modules.