# -*- mode: ruby -*-
# vi: set ft=ruby :

# Useful info
# https://learn.microsoft.com/en-us/virtualization/community/team-blog/2017/20170706-vagrant-and-hyper-v-tips-and-tricks
# https://learn.microsoft.com/en-us/virtualization/community/team-blog/2017/20170718-copying-files-into-a-hyper-v-vm-with-vagrant
# https://superuser.com/questions/1354658/hyperv-static-ip-with-vagrant
# https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network
#
# Important!
# https://opentechtips.com/how-to-create-nat-ed-subnets-in-hyper-v/
# https://mytechiethoughts.com/windows/hyper-v-default-switch-easy-lan-internet-access-for-guest-vms/
# https://automatingops.com/allowing-windows-subsystem-for-linux-to-communicate-with-hyper-v-vms
# https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/

# TODO: Check if needed
# ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/ubuntu2204"
VAGRANT_BOX_VERSION = "4.3.10"
HYPERV_SWITCH       = "K8sLabSwitch"
COUNT_LB            = 2
COUNT_CP_NODES      = 3
COUNT_WORKER_NODES  = 3

Vagrant.configure(2) do |config|

  # Setup static IP for the given vSwitch
  config.vm.provision "staticip", type: "shell", path: "scripts/static_ip.sh", reset: true

  # Upgrade system and kernel
  config.vm.provision "update", type: "shell", path: "scripts/update.sh", reboot: true

  # Just upload files to VMs, synced folders with Hyper-V are problematic
  config.vm.provision "uploadfiles", type: "file", run: "always", source: "ansible", destination: "/home/vagrant/k8s-ansible"

  # Need to clarify why auto mount sync folder didn't work OOB
  # Enable-WindowsOptionalFeature -Online -FeatureName SmbDirect -All -Verbose
  # config.vagrant.sensitive = [ENV["SMB_USR"], ENV["SMB_PSW"]]
  # config.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: ENV["SMB_USR"], smb_password: ENV["SMB_PSW"]
  config.vm.synced_folder ".", "/vagrant", disabled: true

  (1..COUNT_LB).each do |i|

    config.vm.define "lb#{i}" do |lb|

      lb.vm.box              = VAGRANT_BOX
      lb.vm.box_check_update = false
      lb.vm.box_version      = VAGRANT_BOX_VERSION
      lb.vm.hostname         = "lb#{i}.lab.local"

      lb.vm.network "public_network", bridge: HYPERV_SWITCH

      lb.vm.provider :hyperv do |v|
        v.maxmemory = 1024
        v.memory    = 768
        v.cpus      = 1

        v.enable_virtualization_extensions = true
        v.linked_clone                     = true
        v.vm_integration_services          = {
          guest_service_interface: true
        }
      end

      lb.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.5#{i}"
      }

      lb.vm.provision "update", type: "shell"

      # Allow to run single provisioner by specifying name
      # vagrant provision lb1 --provision-with mainconfig
      lb.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/home/vagrant/k8s-ansible"
        ans.playbook = "lb.yaml"
      end

    end

  end

  (1..COUNT_CP_NODES).each do |i|

    config.vm.define "km#{i}" do |cp|

      cp.vm.box              = VAGRANT_BOX
      cp.vm.box_check_update = false
      cp.vm.box_version      = VAGRANT_BOX_VERSION
      cp.vm.hostname         = "km#{i}.lab.local"

      cp.vm.network "private_network", bridge: HYPERV_SWITCH

      cp.vm.provider :hyperv do |v|
        # kubeadm requires at least 1700Mb
        v.maxmemory = 2048
        v.memory    = 2048
        v.cpus      = 4

        v.enable_virtualization_extensions = true
        v.linked_clone                     = true
        v.vm_integration_services          = {
          guest_service_interface: true
        }
      end

      cp.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.10#{i}"
      }

      cp.vm.provision "update", type: "shell"

      cp.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/home/vagrant/k8s-ansible"
        ans.playbook = "kmaster.yaml"
        ans.verbose = "-v"
      end

    end

  end

  (1..COUNT_WORKER_NODES).each do |i|

    config.vm.define "kw#{i}" do |wrk|

      wrk.vm.box              = VAGRANT_BOX
      wrk.vm.box_check_update = false
      wrk.vm.box_version      = VAGRANT_BOX_VERSION
      wrk.vm.hostname         = "kw#{i}.lab.local"

      wrk.vm.network "private_network", bridge: HYPERV_SWITCH

      wrk.vm.provider :hyperv do |v|
        v.maxmemory = 2048
        v.memory    = 2048
        v.cpus      = 4

        v.enable_virtualization_extensions = true
        v.linked_clone                     = true
        v.vm_integration_services          = {
          guest_service_interface: true
        }
      end

      wrk.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.20#{i}"
      }

      wrk.vm.provision "update", type: "shell"

      wrk.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/home/vagrant/k8s-ansible"
        ans.playbook = "kworker.yaml"
        ans.verbose = "-v"
      end

    end

  end

end
