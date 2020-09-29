# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "Overlay-TZ"
}
 
data "nsxt_policy_transport_zone" "vlan_tz" {
    display_name = "VLAN-TZ"
}
 
data "nsxt_policy_edge_cluster" "edge_cluster" {
    display_name = "TF"
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
 
data "nsxt_policy_edge_node" "edge_node_1" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.edge_cluster.path
    display_name        = var.edge_node_1
}
 
data "nsxt_policy_edge_node" "edge_node_2" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.edge_cluster.path
    display_name        = var.edge_node_2
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
 
# Create NSX-T VLAN Segments
resource "nsxt_policy_vlan_segment" "vlan101" {
    display_name = "VLAN101"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["101"]
}
 
resource "nsxt_policy_vlan_segment" "vlan102" {
    display_name = "VLAN102"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["102"]
}
 
# Create Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "tier0_gw" {
    display_name              = "TF_Tier_0"
    description               = "Tier-0 provisioned by Terraform"
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = false
    enable_firewall           = false
    force_whitelisting        = true
    ha_mode                   = "ACTIVE_STANDBY"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
 
    bgp_config {
        ecmp            = false              
        local_as_num    = "65003"
        inter_sr_ibgp   = false
        multipath_relax = false
    }
 
    tag {
        scope = "color"
        tag   = "blue"
    }
}
 
# Create Tier-0 Gateway Uplink Interfaces
resource "nsxt_policy_tier0_gateway_interface" "uplink1" {
    display_name        = "Uplink-01"
    description         = "Uplink to VLAN101"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge_node_1.path
    gateway_path        = nsxt_policy_tier0_gateway.tier0_gw.path
    segment_path        = nsxt_policy_vlan_segment.vlan101.path
    subnets             = ["192.168.101.254/24"]
    mtu                 = 1500
}
 
resource "nsxt_policy_tier0_gateway_interface" "uplink2" {
    display_name        = "Uplink-02"
    description         = "Uplink to VLAN102"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge_node_2.path
    gateway_path        = nsxt_policy_tier0_gateway.tier0_gw.path
    segment_path        = nsxt_policy_vlan_segment.vlan102.path
    subnets             = ["192.168.102.254/24"]
    mtu                 = 1500
}
 
# BGP Neighbor Configuration
resource "nsxt_policy_bgp_neighbor" "router_a" {
    display_name        = "ToR-A"
    description         = "Terraform provisioned BGP Neighbor Configuration"
    bgp_path            = nsxt_policy_tier0_gateway.tier0_gw.bgp_config.0.path
    neighbor_address    = "192.168.101.1"
    remote_as_num       = "65001"
}
 
resource "nsxt_policy_bgp_neighbor" "router_b" {
    display_name        = "ToR-B"
    description         = "Terraform provisioned BGP Neighbor Configuration"
    bgp_path            = nsxt_policy_tier0_gateway.tier0_gw.bgp_config.0.path
    neighbor_address    = "192.168.102.1"
    remote_as_num       = "65002"
}
 
# Create Tier-1 Gateway
resource "nsxt_policy_tier1_gateway" "tier1_gw" {
    description               = "Tier-1 provisioned by Terraform"
    display_name              = "TF-Tier-1-01"
    nsx_id                    = "predefined_id"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = "false"
    enable_firewall           = "true"
    enable_standby_relocation = "false"
    force_whitelisting        = "true"
    tier0_path                = nsxt_policy_tier0_gateway.tier0_gw.path
    route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
 
    tag {
        scope = "color"
        tag   = "blue"
    }
 
    route_advertisement_rule {
        name                      = "Tier 1 Networks"
        action                    = "PERMIT"
        subnets                   = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
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
        cidr        = "172.16.10.1/24"
        # dhcp_ranges = ["172.16.10.50-172.16.10.100"] 
     
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
        cidr        = "172.16.20.1/24"
    }
}
 
resource "nsxt_policy_segment" "tf_segment_db" {
    display_name = var.nsx_segment_db
    description = "Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path
 
    subnet {   
        cidr        = "172.16.30.1/24"
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