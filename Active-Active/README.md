This example shows how you can use the Terraform NSX-T Provider to quickly configure an Active-Active Tier-0 with a Tier-1 and a 3-tier app topology.

This Terraform NSX-T Provider example can be useful to quickly deploy a typical 3-tier application topology on a NSX-T environment to test and configures the following NSX-T objects: 

- Active-Active Tier-0 Gateway
- Uplink interfaces on the Tier-0 Gateway
- BGP Configuration on the Tier-0 Gateway,
- BGP Neighbor Configuration with ECMP
- Tier-1 Gateway
- Route Advertisement rule on the Tier-1
- Overlay Segments for the Web, App and DB tiers. 
- VLAN101 Segment for north-south traffic and BGP peering with ToR-A
- VLAN102 Segment for north-south traffic and BGP peering with ToR-B
- Local NSX-T DHCP Server for the Segments 
- Security Groups for the Web, App and DB tiers based on Tags
- Custom Service (TCP 8443) for Web to App communication.
- Distributed Firewall Rules for accessing the Application and communication between the tiers, including a default deny rule and using Applied To.

Requirements:

- NSX Manager(s) ready and configured
- Compute Manager configured
- Overlay and VLAN Transport Zones configured
- Two Edge Nodes configured
- Edge Cluster configured with the two Edge Nodes as members.