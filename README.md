# Kubernetes on Hyper-V with Vagrant, Ansible & kubeadm

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

# Enable NAT
New-NetNat -name "K8sNAT" -InternalIPInterfaceAddressPrefix 172.16.0.0/24
```

## Start Kubernetes setup

For Vagrant to work with Hyper-V - Terminal must be run as Administrator user

```powershell
vagrant up loadbalancer1 loadbalancer2 --parallel
vagrant up kmaster1 kmaster2 kmaster3 kworker1 --parallel
```
