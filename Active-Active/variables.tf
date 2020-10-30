# Variables
# NSX Manager IP
variable "nsx_manager" {
  default = "10.29.12.206"
}

# Username & Password for NSX-T Manager
variable "username" {
  default = "admin"
}

variable "password" {
  default = "password"
}

# Transport Zones & MTU
variable "vlan_tz" {
  default = "VLAN-TZ"
}

variable "overlay_tz" {
  default = "Overlay-TZ"
}

variable "tier0_uplink_mtu" {
  default = "1500"
}


# Enter Edge Nodes Display Name. Required for external interfaces.
variable "edge_node_1" {
  default = "edge-01"
}
variable "edge_node_2" {
  default = "edge-02"
}

variable "edge_cluster" {
  default = "edge-cluster-01"
}

# Tier0 Gateway Configuration
variable "tier0_local_as" {
  default = 65005
}

variable "uplink_en1_fa_ip" {
  default = "192.168.101.254/24"
}

variable "uplink_en1_fb_ip" {
  default = "192.168.102.254/24"
}

variable "uplink_en2_fa_ip" {
  default = "192.168.101.253/24"
}

variable "uplink_en2_fb_ip" {
  default = "192.168.102.253/24"
}

variable "router_a_ip" {
  default = "192.168.101.1"
}

variable "router_b_ip" {
  default = "192.168.102.1"
}

variable "router_a_remote_as" {
  default = "65001"
}

variable "router_b_remote_as" {
  default = "65002"
}

variable "hold_down_time" {
  default = "180"
}

variable "keep_alive_time" {
  default = "60"
}

# Segment Names and Details
variable "segment_web" {
  default = "TF-Segment-Web"
}

variable "segment_app" {
  default = "TF-Segment-App"
}

variable "segment_db" {
  default = "TF-Segment-DB"
}

variable "segment_web_cidr" {
  default = "172.16.10.1/24"
}

variable "segment_app_cidr" {
  default = "172.16.20.1/24"
}

variable "segment_db_cidr" {
  default = "172.16.30.1/24"
}

# Security Group names
variable "nsx_group_web" {
  default = "Web Servers"
}

variable "nsx_group_app" {
  default = "App Servers"
}

variable "nsx_group_db" {
  default = "DB Servers"
}

variable "nsx_group_blue" {
  default = "Blue Application"
}
