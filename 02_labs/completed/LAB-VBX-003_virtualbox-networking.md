# LAB-VBX-003 - Oracle VirtualBox Networking

## Status

**PASS**

## Objective

Validate VirtualBox networking modes and understand their security,
routing and isolation characteristics.

## Systems

- LAB-VBOX-LINUX-001
- LAB-VBOX-LINUX-002
- Debian GNU/Linux 13.6
- Oracle VirtualBox 7.2.14
- Guest Additions 7.2.14

## Tested networking modes

The following modes were tested:

1. NAT
2. NAT with localhost-only SSH port forwarding
3. Host-only
4. NAT + Host-only
5. NAT Network
6. Internal Network
7. Bridged Adapter

## NAT

NAT provided outbound Internet access while preventing direct host
access to the guest's SSH service.

A temporary forwarding rule exposed SSH only through:

127.0.0.1:2222

The same port was not exposed through the physical Wi-Fi address.

## Host-only

Host-only provided direct communication between Windows and the guest
using:

192.168.56.0/24

Internet access was unavailable.

## NAT + Host-only

Two interfaces were used simultaneously.

Host-only provided the management path.

NAT provided the default route to the Internet.

The routing decision was verified explicitly.

## NAT Network

A reusable NAT Network was created:

LAB-NATNET-01
10.20.30.0/24

Both guests received DHCP addresses and communicated directly with
each other while retaining Internet access.

## Internal Network

An isolated network was created:

LAB-INTNET-01
172.16.50.0/24

The guests communicated with each other using ICMP and SSH.

The host and Internet were unreachable.

This configuration is suitable for isolated attacker-target exercises.

## Bridged networking

LAB-VBOX-LINUX-002 was temporarily bridged to:

Intel(R) Wi-Fi 6 AX201 160MHz

The guest received:

192.168.1.13

from the physical LAN DHCP server.

The guest could access the router and Internet and was directly
reachable from the Windows host through TCP/22.

## Clone preparation

LAB-VBOX-LINUX-002 was created as a full clone from the validated
LAB-VBOX-LINUX-001 baseline.

Before simultaneous networking tests the clone received:

- unique hostname;
- unique machine-id;
- regenerated SSH host keys;
- unique VirtualBox MAC address;
- unique VM UUID.

## Security conclusions

Internal Network provides the strongest isolation among the tested
multi-VM configurations.

Host-only is suitable for host-managed isolated guests.

NAT + Host-only is the preferred general-purpose laboratory profile
when both host management and Internet access are needed.

NAT Network is suitable for multiple guests requiring mutual
communication and outbound Internet access.

Bridged networking exposes the VM directly to the physical LAN and
should therefore be used only when the laboratory requires it.

## Final state

Both guests were restored to their validated snapshots.

Both guests are powered off.

Both guests use NAT on NIC 1.

Secondary NICs are disabled.

LAB-NATNET-01 remains defined for future laboratories.

## Result

**PASS**
