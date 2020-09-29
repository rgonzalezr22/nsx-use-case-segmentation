This example shows how we could use Terraform to create the segments and IP pools in NSX-T to get started with deploying Edge Nodes and configuring Transport Nodes.

To get started you have to have a NSX Manager, Compute Manager registered, Transport Zones configured and a NSX License added.

Once this all is done we are going to create the following objects with Terraform to get started with the Lab:

- TEP IP Pool for Geneve TEPs for Transport Nodes in VLAN 12
- TEP IP Pool for Geneve TEPs for Transport Nodes in VLAN 100
- TEP IP Pool for Geneve TEPs for Transport Nodes in VLAN 200
- VLAN Segment for vSphere VMkernel interfaces (VLAN 11)
- VLAN Segments for Geneve Transport Networks (VLAN 12, 100 and 200)
- VLAN Segment (VLAN 307) for connecting Edge Node Management interface (eth0)
- VLAN Trunk Segments to connect Edge Node DPDK interfaces (fp-eth0 and fp-eth1) for Collapsed Compute + Edge node topology testing.