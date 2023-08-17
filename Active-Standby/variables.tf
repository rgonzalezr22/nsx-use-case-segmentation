# Variables
 
variable "nsx_manager" {
    default = "172.16.0.11"
}
 
# Username & Password for NSX-T Manager
variable "username" {
  default = "admin"
}
 
variable "password" {
    default = "dAyhMYKEcvaPf=8W"
}
 
# Enter Edge Nodes Display Name. Required for external interfaces.
variable "edge_node_1" {
    default = "edge-01"
}
variable "edge_node_2" {
    default = "edge-02"
}
 
# Segment Names
variable "nsx_segment_web" {
    default = "TF-Segment-Web"
}
variable "nsx_segment_app" {
    default = "TF-Segment-App"
}
 
variable "nsx_segment_db" {
    default = "TF-Segment-DB"
}
 
# Security Group names.
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
