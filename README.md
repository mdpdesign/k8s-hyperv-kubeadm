# Kubernetes on Hyper-V with Vagrant, Ansible & kubeadm

This is a "lab" Kubernetes HA setup with 3 control-plane nodes and 1 or more worker nodes + NFS server for storage and 2 loadbalancer VMs. Loadbalancer VMs use `keepalived` and `HAProxy` for HA.

Kubernetes setup includes:

- [Calico](https://docs.tigera.io/calico/latest/about/) CNI
- [Metallb](https://metallb.universe.tf/) deployment for `LoadBalancer` type services
- [Traefik](https://traefik.io/traefik/) ingress controller
- Control Plane tools:
  - [helm](https://helm.sh/)
  - [k9s](https://k9scli.io/)
  - `k`, `kn` & `h` aliases for kubectl and helm + autocompletion

![Kubernetes HA diagram](./docs/k8s-ha-hyperv-sketch.drawio.svg)

This whole setup is configured to run on Windows with Hyper-V as provider

Minimum host requirements

- Windows 10/11 Professional or Server edition (tested on Windows 10 and 11)
- Min. 4 core CPU recommended
- Min. 16GB of RAM **required** (adjust VMs memory accordingly in `Vagrantfile`)
- Hyper-V feature enabled

## Steps required for installation

Installing Windows Hyper-V feature:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

Install Vagrant

Using `winget` or by downloading installation package

```powershell
winget install Vagrant
```

Create Hyper-V dedicated Switch for K8s Lab - https://opentechtips.com/how-to-create-nat-ed-subnets-in-hyper-v/, name it `K8sLabSwitch`, use `172.16.0.1` for IP address

```powershell
# Create Hyper-V switch
New-VMSwitch -Name "K8sLabSwitch" -SwitchType Internal

# Configure interface
$IfIndex = Get-NetAdapter | Where-Object { $_.Name -match "K8sLabSwitch" }
New-NetIPAddress –IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceIndex $IfIndex.InterfaceIndex

# Enable NAT for VMs to connect to internet etc.
New-NetNat -name "K8sNAT" -InternalIPInterfaceAddressPrefix 172.16.0.0/24

# Enable forwarding - for e.g. to access cluster from WSL
# This command must be run sometimes on every reboot of the host
Get-NetIPInterface | where {$_.InterfaceAlias -match 'vEthernet \(WSL' -or $_.InterfaceAlias -eq 'vEthernet (Default Switch)' -or $_.InterfaceAlias -match 'K8sLabSwitch'} | Set-NetIPInterface -Forwarding Enabled -Verbose
```

## Start Kubernetes setup

For Vagrant to work with Hyper-V - Terminal must be run as Administrator user

```powershell
# 1. Create all VMs and run only shell provisioner, this will assign static IP and update the system
vagrant up --provision-with shell

# 2. Setup load balancers and bootstrap Kubernetes on all VMs
vagrant provision --provision-with uploadfiles,bootstrap

# 3. Install metallb, ingress controller and monitoring, this provisioner is not executed by default
# as Kubernetes cluster must be bootstrapped first to be able to schedule workloads etc.
vagrant provision km1 --provision-with uploadfiles,addons
```

Stopping Kubernetes setup

```powershell
vagrant halt
```

Destroying Kubernetes setup

```powershell
vagrant destroy

# or
vagrant destroy --force
```

## Development

For development purposes or to play around with just Kubernetes setup & Ansible it's easier to first provision VMs with static IP and updates,
then create a snapshot, so that VMs can be restored easily omiting the initial setup (saving some time). For e.g:

```powershell
# Create all VMs and run only shell provisioners
vagrant up --provision-with shell

# or create only selected VMs and run shell provisioners
vagrant up lb1 lb2 km1 km2 km3 kw1 ... --provision-with shell

# or to be more specific
# for all VMs
vagrant up --provision-with staticip,update

# for selected VMs
vagrant up lb1 lb2 km1 km2 km3 kw1 ... --provision-with staticip,update

# then create checkpoint/snapshot either via Hyper-V GUI or
# for all VMs
vagrant snapshot save initial-setup

# for selected VMs
vagrant snapshot save lb1 lb2 km1 km2 km3 kw1 ... initial-setup
```

Running only main provisioning after VMs are set up with static IP and updates:

```powershell
# for all VMs
vagrant up --provision-with uploadfiles,bootstrap

# for selected VMs
vagrant up lb1 lb2 km1 km2 km3 kw1 ... --provision-with uploadfiles,bootstrap
```

Other useful commands

```powershell
# Start/Stop VMs
Get-VM | Start-VM
Get-VM | Stop-VM

# Quickly restore all VMs from snapshot
Get-VM | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false

# Restore only some VMs from snapshot
Get-VM -Name "*lb*" | Get-VMSnapshot | Restore-VMSnapshot -Confirm:$false
```

Resetting kubeadm init:

```bash
sudo kubeadm reset
sudo kubeadm init...
```

Verify if we can connect from within WSL instance to Kubernetes cluster

```bash
curl -v -k https://172.16.0.100:6443/healthz
```

## Recommended tools to work easier with Kubernetes

- https://github.com/derailed/k9s
- https://github.com/ahmetb/kubectx

## TODO

- [Registry](https://goharbor.io/)
- [Ansible Hyper-V scripts](https://github.com/jamiely/ansible-hyperv/tree/master)
