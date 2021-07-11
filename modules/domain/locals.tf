#__________________________________________________________
#
# Local Variables Section
#__________________________________________________________

#__________________________________________________________
#
# Assign Global Attributes from global_vars Workspace
#__________________________________________________________

locals {
  # Intersight Organization Variables
  org_name = var.organization
  org_moid = data.intersight_organization_organization.org_moid.results.0.moid

  # Intersight Provider Variables
  endpoint = var.endpoint

  # Tags for Deployment
  tags = data.terraform_remote_state.global.outputs.tags
  serial_a = var.hcl_variables.serial_a == null ? "" : var.hcl_variables.serial_a
  serial_b = var.hcl_variables.serial_b == null ? "" : var.hcl_variables.serial_b
}
