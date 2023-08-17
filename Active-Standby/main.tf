# Data Sources we need for reference later

terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}


data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "TZ-OVERLAY"
}
 
data "nsxt_policy_edge_cluster" "edge-cluster" {
    display_name = "edge-cluster"
}
 
data "nsxt_policy_service" "ssh" {
    display_name = "SSH"
}
 
data "nsxt_policy_service" "http" {
    display_name = "HTTP"
}
 
data "nsxt_policy_service" "https" {
    display_name = "HTTPS"
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
 
data "nsxt_policy_tier0_gateway" "T0" {
  display_name = "Provider-LR"
}

# Create Tier-1 Gateway
resource "nsxt_policy_tier1_gateway" "tier1_gw" {
    description               = "Tier-1 provisioned by Terraform"
    display_name              = "TF-Tier-1-01"
    nsx_id                    = "predefined_id"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster.path
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = "false"
    enable_firewall           = "true"
    enable_standby_relocation = "false"
    force_whitelisting        = "true"
    tier0_path                = nsxt_policy_tier0_gateway.T0.path
    route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
 
    tag {
        scope = "color"
        tag   = "blue"
    }
 
    route_advertisement_rule {
        name                      = "Tier 1 Networks"
        action                    = "PERMIT"
        subnets                   = ["10.10.20.0/24", "10.10.30.0/24", "10.10.40.0/24"]
        prefix_operator           = "GE"
        route_advertisement_types = ["TIER1_CONNECTED"]
    }
}
 
# Create NSX-T Overlay Segments
resource "nsxt_policy_segment" "tf_segment_web" {
    display_name        = var.nsx_segment_web
    description         = "Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path
 
    subnet {   
        cidr        = "10.10.20.1/24"
        # dhcp_ranges = ["10.10.20.50-10.10.20.100"] 
     
        # dhcp_v4_config {
        #     lease_time  = 36000
        #     dns_servers = ["10.29.12.197"]
        # }
    }
}
 
resource "nsxt_policy_segment" "tf_segment_app" {
    display_name = var.nsx_segment_app
    description = "Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path
 
    subnet {   
        cidr        = "10.10.30.0/24"
    }
}
 
resource "nsxt_policy_segment" "tf_segment_db" {
    display_name = var.nsx_segment_db
    description = "Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path
 
    subnet {   
        cidr        = "10.10.40.0/24"
    }
     
}
 
# Create Security Groups
resource "nsxt_policy_group" "web_servers" {
    display_name = var.nsx_group_web
    description  = "Terraform provisioned Group"
 
    criteria {
        condition {
            key         = "Tag"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "Web"
        }
    }
}
 
resource "nsxt_policy_group" "app_servers" {
    display_name = var.nsx_group_app
    description  = "Terraform provisioned Group"
 
    criteria {
        condition {
            key         = "Tag"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "App"
        }
    }
}
 
resource "nsxt_policy_group" "db_servers" {
    display_name = var.nsx_group_db
    description  = "Terraform provisioned Group"
 
    criteria {
        condition {
            key         = "Tag"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "DB"
        }
    }
}
 
resource "nsxt_policy_group" "blue_servers" {
    display_name = var.nsx_group_blue
    description  = "Terraform provisioned Group"
 
    criteria {
        condition {
            key         = "Tag"
            member_type = "VirtualMachine"
            operator    = "CONTAINS"
            value       = "Blue"
        }
    }
}
 
# Create Custom Services
resource "nsxt_policy_service" "service_tcp8443" {
    description  = "HTTPS service provisioned by Terraform"
    display_name = "TCP 8443"
 
    l4_port_set_entry {
        display_name      = "TCP8443"
        description       = "TCP port 8443 entry"
        protocol          = "TCP"
        destination_ports = [ "8443" ]
    }
 
    tag {
        scope = "color"
        tag   = "blue"
    }
}
 
# Create Security Policies
resource "nsxt_policy_security_policy" "allow_blue" {
    display_name = "Allow Blue Application"
    description  = "Terraform provisioned Security Policy"
    category     = "Application"
    locked       = false
    stateful     = true
    tcp_strict   = false
    scope        = [nsxt_policy_group.web_servers.path]
 
    rule {
        display_name        = "Allow SSH to Blue Servers"
        destination_groups  = [nsxt_policy_group.blue_servers.path]
        action              = "ALLOW"
        services            = [data.nsxt_policy_service.ssh.path]
        logged              = true
        scope               = [nsxt_policy_group.blue_servers.path]
    }   
 
    rule {
        display_name        = "Allow HTTPS to Web Servers"
        destination_groups  = [nsxt_policy_group.web_servers.path]
        action              = "ALLOW"
        services            = [data.nsxt_policy_service.https.path]
        logged              = true
        scope               = [nsxt_policy_group.web_servers.path]
    }
 
    rule {
        display_name        = "Allow TCP 8443 to App Servers"
        source_groups       = [nsxt_policy_group.web_servers.path]
        destination_groups  = [nsxt_policy_group.app_servers.path]
        action              = "ALLOW"
        services            = [nsxt_policy_service.service_tcp8443.path]
        logged              = true
        scope               = [nsxt_policy_group.web_servers.path,nsxt_policy_group.app_servers.path]
    }
 
    rule {
        display_name        = "Allow HTTP to DB Servers"
        source_groups       = [nsxt_policy_group.app_servers.path]
        destination_groups  = [nsxt_policy_group.db_servers.path]
        action              = "ALLOW"
        services            = [data.nsxt_policy_service.http.path]
        logged              = true
        scope               = [nsxt_policy_group.app_servers.path,nsxt_policy_group.db_servers.path]
    }
 
    rule {
        display_name        = "Any Deny"
        action              = "REJECT"
        logged              = false
        scope               = [nsxt_policy_group.blue_servers.path]
    }
}
