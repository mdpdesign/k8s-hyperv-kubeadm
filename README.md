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
