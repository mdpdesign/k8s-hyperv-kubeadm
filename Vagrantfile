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

Vagrant.configure(2) do |config|

  # Setup static IP for the given vSwitch
  config.vm.provision "staticip", type: "shell", path: "scripts/static_ip.sh", reset: true

  # Just upload files to VMs, synced folders with Hyper-V are problematic
  config.vm.provision "uploadfiles", type: "file", run: "always", source: "ansible", destination: "/tmp/ansible"

  # Need to clarify why auto mount sync folder didn't work OOB
  # Enable-WindowsOptionalFeature -Online -FeatureName SmbDirect -All -Verbose
  # config.vagrant.sensitive = [ENV["SMB_USR"], ENV["SMB_PSW"]]
  # config.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: ENV["SMB_USR"], smb_password: ENV["SMB_PSW"]
  
  box_name = "generic/ubuntu2204"
  box_version = "4.3.10"

  # Load Balancer Nodes
  LoadBalancerCount = 2

  (1..LoadBalancerCount).each do |i|

    config.vm.define "lb#{i}" do |lb|

      lb.vm.box               = box_name
      lb.vm.box_check_update  = false
      lb.vm.box_version       = box_version
      lb.vm.hostname          = "lb#{i}.lab.local"

      lb.vm.network "public_network", bridge: "K8sLabSwitch"

      lb.vm.provider :hyperv do |v|
        v.memory  = 768
        v.cpus    = 1

        v.enable_virtualization_extensions  = true
        v.linked_clone = true
        v.vm_integration_services = {
          guest_service_interface: true
        }
      end

      lb.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.5#{i}"
      }

      # Allow to run single provisioner by specifying name
      # vagrant provision lb1 --provision-with mainconfig
      lb.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/tmp/ansible"
        ans.playbook = "lb.yaml"
      end

    end

  end


  # Kubernetes Master Nodes
  MasterCount = 3

  (1..MasterCount).each do |i|

    config.vm.define "km#{i}" do |masternode|

      masternode.vm.box               = box_name
      masternode.vm.box_check_update  = false
      masternode.vm.box_version       = box_version
      masternode.vm.hostname          = "km#{i}.lab.local"

      masternode.vm.network "private_network", bridge: "K8sLabSwitch"

      masternode.vm.provider :hyperv do |v|
        # kubeadm requires at least 1700Mb
        v.memory  = 2048
        v.cpus    = 2

        v.enable_virtualization_extensions  = true
        v.linked_clone = true
        v.vm_integration_services = {
          guest_service_interface: true
        }
      end

      masternode.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.10#{i}"
      }

      masternode.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/tmp/ansible"
        ans.playbook = "kmaster.yaml"
        ans.verbose = "-v"
      end

    end

  end


  # Kubernetes Worker Nodes
  WorkerCount = 1

  (1..WorkerCount).each do |i|

    config.vm.define "kw#{i}" do |workernode|

      workernode.vm.box               = box_name
      workernode.vm.box_check_update  = false
      workernode.vm.box_version       = box_version
      workernode.vm.hostname          = "kw#{i}.lab.local"

      workernode.vm.network "private_network", bridge: "K8sLabSwitch"

      workernode.vm.provider :hyperv do |v|
        v.memory  = 2048
        v.cpus    = 2

        v.enable_virtualization_extensions  = true
        v.linked_clone = true
        v.vm_integration_services = {
          guest_service_interface: true
        }
      end

      workernode.vm.provision "staticip", type: "shell", env: {
        IP_ADDRESS: "172.16.0.20#{i}"
      }

      workernode.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/tmp/ansible"
        ans.playbook = "kworker.yaml"
        ans.verbose = "-v"
      end

    end

  end

end
