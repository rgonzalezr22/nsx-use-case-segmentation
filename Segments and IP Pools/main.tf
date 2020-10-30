# Prerequisites:
# 1. Add NSX-T License
 
# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "Overlay-TZ"
}
 
data "nsxt_policy_transport_zone" "vlan_tz" {
    display_name = "VLAN-TZ"
}
 
# NSX-T Manager Credentials
provider "nsxt" {
    host                     = var.nsx_manager
    username                 = var.username
    password                 = var.password
    allow_unverified_ssl     = true
    max_retries              = 10
    retry_min_delay          = 500
    retry_max_delay          = 5000
    retry_on_status_codes    = [429]
}
 
# Create TEP IP Pools
resource "nsxt_policy_ip_pool" "tep_ip_pool_vlan12" {
    display_name = "TEP-IP-Pool-VLAN12"
}
 
resource "nsxt_policy_ip_pool_static_subnet" "tep_ip_pool_vlan12" {
    display_name = "TEP-IP-Pool-VLAN12"
    pool_path = nsxt_policy_ip_pool.tep_ip_pool_vlan12.path
    cidr                = "172.16.12.0/24"
    gateway             = "172.16.12.1"
 
    allocation_range {
        start = "172.16.12.11"
        end   = "172.16.12.100"
  }
}
 
resource "nsxt_policy_ip_pool" "tep_ip_pool_vlan100" {
    display_name = "TEP-IP-Pool-VLAN100"
}
 
resource "nsxt_policy_ip_pool_static_subnet" "tep_ip_pool_vlan100" {
    display_name = "TEP-IP-Pool-VLAN100"
    pool_path = nsxt_policy_ip_pool.tep_ip_pool_vlan100.path
    cidr                = "192.168.100.0/24"
    gateway             = "192.168.100.1"
 
    allocation_range {
        start = "192.168.100.11"
        end   = "192.168.100.100"
  }
}
 
resource "nsxt_policy_ip_pool" "tep_ip_pool_vlan200" {
    display_name = "TEP-IP-Pool-VLAN200"
}
 
resource "nsxt_policy_ip_pool_static_subnet" "tep_ip_pool_vlan200" {
    display_name = "TEP-IP-Pool-VLAN200"
    pool_path = nsxt_policy_ip_pool.tep_ip_pool_vlan200.path
    cidr                = "192.168.200.0/24"
    gateway             = "192.168.200.1"
 
    allocation_range {
        start = "192.168.200.11"
        end   = "192.168.200.100"
  }
}
 
# Create NSX-T VLAN Segments
resource "nsxt_policy_vlan_segment" "vlan11" {
    display_name = "VLAN11"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["11"]
}
 
resource "nsxt_policy_vlan_segment" "vlan100" {
    display_name = "VLAN100"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["100"]
}
 
resource "nsxt_policy_vlan_segment" "vlan200" {
    display_name = "VLAN200"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["200"]
}
 
resource "nsxt_policy_vlan_segment" "trunk_a" {
    display_name = "Trunk-A"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["100", "101", "102", "200"]
}
 
resource "nsxt_policy_vlan_segment" "trunk_b" {
    display_name = "Trunk-B"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["100", "101", "102", "200"]
}
 
resource "nsxt_policy_vlan_segment" "vlan307" {
    display_name = "VLAN307"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["307"]
}