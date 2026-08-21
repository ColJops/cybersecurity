# TR-2026-007 - Oracle VirtualBox Networking Baseline

## 1. Metadata

- Report ID: TR-2026-007
- Laboratory: LAB-VBX-003
- Platform: Windows 11 Pro 25H2 / Oracle VirtualBox 7.2.14
- Guests: Debian GNU/Linux 13.6
- Result: **PASS**

## 2. Objective

Evaluate the main Oracle VirtualBox networking modes using controlled
two-VM laboratory scenarios.

## 3. NAT

NAT baseline:

- guest address: 10.0.2.15/24
- gateway: 10.0.2.2
- Internet: available
- DNS: available
- direct inbound SSH from host: unavailable

## 4. NAT port forwarding

Temporary rule:

127.0.0.1:2222 -> guest:22

Result:

- localhost access: PASS
- physical LAN exposure: BLOCKED

## 5. Host-only

Network:

192.168.56.0/24

Host:

192.168.56.1

Guest:

192.168.56.10

Result:

- host-guest communication: PASS
- Internet isolation: PASS

## 6. NAT + Host-only

Management traffic used Host-only.

Internet traffic used a separate NAT adapter.

Result:

PASS

## 7. NAT Network

Network:

LAB-NATNET-01
10.20.30.0/24

Observed addresses:

- VM1: 10.20.30.3
- VM2: 10.20.30.4

VM-to-VM communication and Internet access were both validated.

## 8. Internal Network

Network:

LAB-INTNET-01

Addressing:

- VM1: 172.16.50.11/24
- VM2: 172.16.50.12/24

Validated:

- VM-to-VM ICMP
- VM-to-VM SSH
- no default route
- no Internet
- no host access

## 9. Bridged

Physical interface:

Intel(R) Wi-Fi 6 AX201 160MHz

Host:

192.168.1.8

Guest:

192.168.1.13

Router:

192.168.1.1

The guest operated as an independent host on the physical LAN.

## 10. Security comparison

| Mode | Internet | Host access | VM-to-VM | LAN exposure |
| --- | --- | --- | --- | --- |
| NAT | yes | forwarding required | limited | no |
| Host-only | no | yes | yes | no |
| NAT + Host-only | yes | yes | possible | no |
| NAT Network | yes | no direct host membership | yes | no |
| Internal Network | no | no | yes | no |
| Bridged | yes | yes | yes | yes |

## 11. Recommended laboratory usage

Preferred profiles:

- vulnerable target isolation:
  Internal Network

- host-managed isolated guest:
  Host-only

- normal cyberlab workstation:
  NAT + Host-only

- multi-VM Internet-enabled scenario:
  NAT Network

- physical LAN testing:
  Bridged only when required

## 12. Cleanup

Both VMs were restored to validated snapshots after networking tests.

Final VM configuration:

- NIC 1: NAT
- NIC 2: disabled
- state: powered off

LAB-NATNET-01 remains available as reusable infrastructure.

## 13. Result

**PASS**

LAB-VBX-003 successfully validated VirtualBox networking,
multi-VM communication and network isolation behavior.
