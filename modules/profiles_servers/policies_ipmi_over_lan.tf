#_________________________________________________________________________
#
# Intersight IPMI over LAN Policies Variables
# GUI Location: Configure > Policies > Create Policy > IPMI over LAN
#_________________________________________________________________________

variable "ipmi_key_1" {
  default     = ""
  description = "Encryption key 1 to use for IPMI communication. It should have an even number of hexadecimal characters and not exceed 40 characters."
  sensitive   = true
  type        = string
}

variable "policies_ipmi_over_lan" {
  default = {
    default = {
      description  = ""
      enabled      = true
      ipmi_key     = null
      organization = "default"
      privilege    = "admin"
      tags         = []
    }
  }
  description = <<-EOT
  key - Name of the IPMI over LAN Policy.
  * description - Description to Assign to the Policy.
  * enabled - Flag to Enable or Disable the Policy.
  * encryption_key - If null then encryption will not be applied.  If the value is set to 1 it will apply the ipmi_key_1 value.
  * organization - Name of the Intersight Organization to assign this Policy to.
    - https://intersight.com/an/settings/organizations/
  * privilege - The highest privilege level that can be assigned to an IPMI session on a server.
    - admin - Privilege to perform all actions available through IPMI.
    - user - Privilege to perform some functions through IPMI but restriction on performing administrative tasks.
    - read-only - Privilege to view information throught IPMI but restriction on making any changes.
  * tags - List of Key/Value Pairs to Assign as Attributes to the Policy.
  EOT
  type = map(object(
    {
      description  = optional(string)
      enabled      = optional(bool)
      ipmi_key     = optional(number)
      organization = optional(string)
      privilege    = optional(string)
      tags         = optional(list(map(string)))
    }
  ))
}


#_________________________________________________________________________
#
# IPMI over LAN Policies
# GUI Location: Configure > Policies > Create Policy > IPMI over LAN
#_________________________________________________________________________

module "policies_ipmi_over_lan" {
  depends_on = [
    local.org_moids,
    module.ucs_server_profiles
  ]
  source         = "terraform-cisco-modules/imm/intersight//modules/policies_ipmi_over_lan"
  for_each       = local.policies_ipmi_over_lan
  description    = each.value.description != "" ? each.value.description : "${each.key} IPMI over LAN Policy."
  enabled        = each.value.enabled
  encryption_key = each.value.ipmi_key == 1 ? var.ipmi_key_1 : null
  privilege      = each.value.privilege
  name           = each.key
  org_moid       = local.org_moids[each.value.organization].moid
  tags           = length(each.value.tags) > 0 ? each.value.tags : local.tags
  profiles = [
    for s in sort(keys(local.ucs_server_profiles)) :
    module.ucs_server_profiles[s].moid
    if local.ucs_server_profiles[s].profile.policies_ipmi_over_lan == each.key
  ]
}
