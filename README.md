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

Create Hyper-V dedicated Switch for K8s Lab - https://opentechtips.com/how-to-create-nat-ed-subnets-in-hyper-v/, name it `K8sLabSwitch`, use `172.16.0.1` for gateway IP address
