data "aws_region" "current" {}

resource "aws_ecr_repository" "main" {
  name                 = "${terraform.workspace}-sample-nodejs-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "null_resource" "build_image" {
  provisioner "local-exec" {
    command = <<EOT
cd sample-nodejs-app
docker build -t ${terraform.workspace}-sample-nodejs-app .

aws ecr get-login-password | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}
docker tag ${terraform.workspace}-sample-nodejs-app:latest ${aws_ecr_repository.main.repository_url}:latest
docker push ${aws_ecr_repository.main.repository_url}:latest
EOT
  }
}

output "image_name" {
  value = "${aws_ecr_repository.main.repository_url}:latest"
}