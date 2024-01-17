# Kubernetes on Hyper-V with Vagrant, Ansible & kubeadm

This is a "lab" Kubernetes HA setup with 3 control-plane nodes and 1 data-plane worker node + 2 loadbalancer VMs. Loadbalancer VMs use `keepalived` and `HAProxy` for HA

This whole setup is configured to run on Windows with Hyper-V as provider

Minimum host requirements

- Windows 10/11 Professional or Server edition (tested on Windows 10 and 11)
- Min. 4 core CPU recommended
- Min. 16GB of RAM **required**
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
Get-NetIPInterface | where {$_.InterfaceAlias -match 'vEthernet \(WSL' -or $_.InterfaceAlias -eq 'vEthernet (Default Switch)' -or $_.InterfaceAlias -match 'K8sLabSwitch'} | Set-NetIPInterface -Forwarding Enabled -Verbose
```

Verify if we can connect from within WSL instance to Kubernetes cluster

```bash
curl -v -k https://172.16.0.100:6443/healthz
```

## Start Kubernetes setup

For Vagrant to work with Hyper-V - Terminal must be run as Administrator user

```powershell
# Simply
vagrant up

# or when setup was already provisioned before etc.
vagrant up --parallel
vagrant up loadbalancer1 loadbalancer2 --parallel
vagrant up kmaster1 kmaster2 kmaster3 kworker1 --parallel
```

Stopping Kubernetes setup

```powershell
vagrant halt
```

Destroying Kubernetes setup

```powershell
vagrant destroy --force
```

## Development

Running only main provisioning after VMs are set up with static IP:

```powershell
vagrant up km1 --provision-with uploadfiles,mainconfig
```

## Recommended tools to work easier with Kubernetes

- https://github.com/derailed/k9s
- https://github.com/ahmetb/kubectx
