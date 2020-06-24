terraform {
  backend "remote" {
    organization = "Telstra"

    workspaces {
      name = "terraform-registry-test-cli"
    }
  }
}
