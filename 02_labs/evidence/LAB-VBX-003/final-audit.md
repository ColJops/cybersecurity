# LAB-VBX-003 - VirtualBox Networking Final Audit

- Generated: 2026-08-22T00:31:58+02:00
- Assessment: **PASS**
- Platform: Windows 11 Pro 25H2 / Oracle VirtualBox 7.2.14

## Virtual machines

### LAB-VBOX-LINUX-001

- UUID: 6e90c7bc-8231-4435-b1a8-bca9d8077ee5
- State: powered off (since 2026-08-21T22:16:19.629000000)
- Final NIC 1: MAC: 080027161A96, Attachment: NAT, Cable connected: on, Trace: off (file: none), Type: 82540EM, Reported speed: 0 Mbps, Boot priority: 0, Promisc Policy: deny, Bandwidth group: none
- Final NIC 2: disabled
- Snapshot S03-IntegrationValidated present: True

### LAB-VBOX-LINUX-002

- UUID: bba7a2a5-4c7f-4768-97b6-10116bc70db7
- State: powered off (since 2026-08-21T22:16:19.688000000)
- Final NIC 1: MAC: 0800275BF507, Attachment: NAT, Cable connected: on, Trace: off (file: none), Type: 82540EM, Reported speed: 0 Mbps, Boot priority: 0, Promisc Policy: deny, Bandwidth group: none
- Final NIC 2: disabled
- Snapshot S00-CloneIdentityReady present: True

The clone was prepared with:

- unique VirtualBox UUID;
- unique MAC address;
- hostname lab-vbox-linux-002;
- unique Linux machine-id;
- regenerated SSH host keys.

## NAT baseline

VM address observed:

10.0.2.15/24

Default gateway:

10.0.2.2

Validated:

- outbound Internet access: PASS
- DNS resolution: PASS
- HTTPS access: PASS
- direct Host -> Guest SSH: BLOCKED

## NAT port forwarding

Rule tested:

127.0.0.1:2222 -> guest TCP/22

Validated:

- localhost SSH forwarding: PASS
- actual SSH login: PASS
- exposure through host Wi-Fi 192.168.1.8: BLOCKED
- rule removed after validation: PASS

## Host-only network

Host:

192.168.56.1/24

Guest:

192.168.56.10/24

Validated:

- Guest -> Host: PASS
- Host -> Guest SSH: PASS
- Guest -> Internet: BLOCKED

## NAT + Host-only

Guest Host-only interface:

192.168.56.10/24

Guest NAT interface:

10.0.3.15/24

Validated:

- management traffic through Host-only: PASS
- Internet traffic through NAT: PASS
- route separation verified with ip route get: PASS

## NAT Network

Network:

LAB-NATNET-01
10.20.30.0/24

Gateway:

10.20.30.1

DHCP:

enabled

Observed guest addresses:

- LAB-VBOX-LINUX-001: 10.20.30.3
- LAB-VBOX-LINUX-002: 10.20.30.4

Validated:

- VM1 -> VM2 ICMP: PASS
- VM2 -> VM1 ICMP: PASS
- VM1 -> VM2 SSH: PASS
- VM2 -> VM1 SSH: PASS
- Internet from VM1: PASS
- Internet from VM2: PASS
- Host -> VM2 NAT Network address: BLOCKED

## Internal Network

Network name:

LAB-INTNET-01

Addresses:

- LAB-VBOX-LINUX-001: 172.16.50.11/24
- LAB-VBOX-LINUX-002: 172.16.50.12/24

Validated:

- VM1 -> VM2: PASS
- VM2 -> VM1: PASS
- SSH VM1 -> VM2: PASS
- SSH VM2 -> VM1: PASS
- VM1 -> Internet: BLOCKED
- VM2 -> Internet: BLOCKED
- Host -> VM1: BLOCKED
- Host -> VM2: BLOCKED
- default route absent: PASS

## Bridged networking

Physical interface:

Intel(R) Wi-Fi 6 AX201 160MHz

Host LAN address:

192.168.1.8

Guest DHCP address:

192.168.1.13

Router:

192.168.1.1

Validated:

- Guest -> router: PASS
- Guest -> Internet: PASS
- DNS: PASS
- HTTPS: PASS
- Host -> Guest TCP/22: PASS
- guest visible as independent LAN host: PASS

## Networking comparison

| Mode | VM to VM | Host to VM | Internet | Physical LAN exposure |
| --- | --- | --- | --- | --- |
| NAT | limited | only with forwarding | yes | no |
| NAT + local port forwarding | n/a | controlled | yes | no |
| Host-only | yes where applicable | yes | no | no |
| NAT + Host-only | yes where applicable | yes | yes | no |
| NAT Network | yes | no direct membership | yes | no |
| Internal Network | yes | no | no | no |
| Bridged | yes where LAN permits | yes | yes | yes |

## Security interpretation

Recommended default profiles:

- isolated vulnerable targets:
  Internal Network

- controlled host management without Internet:
  Host-only

- controlled host management with Internet:
  NAT + Host-only

- multiple VMs requiring Internet:
  NAT Network

- direct LAN participation:
  Bridged only when explicitly required

Bridged networking should not be the default for intentionally
vulnerable systems or offensive laboratory workloads.

## Cleanup

After testing:

- LAB-VBOX-LINUX-001 restored to S03-IntegrationValidated;
- LAB-VBOX-LINUX-002 restored to S00-CloneIdentityReady;
- both VMs returned to NAT baseline;
- secondary NICs disabled;
- temporary NAT port forwarding removed;
- LAB-NATNET-01 retained as reusable lab infrastructure.

## Validation checks

- VirtualBoxVersionAtLeastBaseline: True
- VM1PoweredOff: True
- VM2PoweredOff: True
- VM1BaselineNAT: True
- VM1NIC2Disabled: True
- VM2BaselineNAT: True
- VM2NIC2Disabled: True
- VMUUIDsUnique: True
- VMMACsUnique: True
- VM1S03Present: True
- VM2CloneBaselinePresent: True
- NatNetworkPresent: True
- NatNetworkAddressCorrect: True
- NatNetworkDHCPEnabled: True
- HostOnlyAvailable: True
- BridgedWifiAvailable: True
- NoInaccessibleMedia: True

## Assessment

**PASS**
