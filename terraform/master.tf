terraform {

required_providers {

null = {

  source = "hashicorp/null"
  version = "~> 3.0"

}


}

}

provider "null" {}

resource "null_resource" "devops_example" {

provisioner "local-exec" {

command = "echo Terraform executed successfully"


}

}
