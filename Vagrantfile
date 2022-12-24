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

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  # Need to clarify why that didn't work OOB
  # Enable-WindowsOptionalFeature -Online -FeatureName SmbDirect -All -Verbose
  # config.vm.synced_folder ".", "/vagrant", type: "smb"
  config.vm.synced_folder ".", "/vagrant"

  # Setup static IP for the given vSwitch
  config.vm.provision "staticip", type: "shell", path: "scripts/static_ip.sh", reboot: true

  # Load Balancer Nodes
  LoadBalancerCount = 2

  (1..LoadBalancerCount).each do |i|

    config.vm.define "loadbalancer#{i}" do |lb|

      lb.vm.box               = "generic/ubuntu2004"
      lb.vm.box_check_update  = false
      lb.vm.box_version       = "4.2.6"
      lb.vm.hostname          = "loadbalancer#{i}.lab.local"

      lb.vm.network "public_network", bridge: "K8sLabSwitch"

      lb.vm.provider :hyperv do |v|
        v.memory  = 512
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
      # vagrant provision loadbalancer1 --provision-with mainconfig
      lb.vm.provision "mainconfig", type: "ansible_local" do |ans|
        ans.provisioning_path = "/vagrant/ansible"
        ans.playbook = "lb.yaml"
      end

    end

  end


  # Kubernetes Master Nodes
  MasterCount = 3

  (1..MasterCount).each do |i|

    config.vm.define "kmaster#{i}" do |masternode|

      masternode.vm.box               = "generic/ubuntu2004"
      masternode.vm.box_check_update  = false
      masternode.vm.box_version       = "4.2.6"
      masternode.vm.hostname          = "kmaster#{i}.lab.local"

      masternode.vm.network "private_network", bridge: "K8sLabSwitch"

      masternode.vm.provider :hyperv do |v|
        v.memory  = 1024
        v.maxmemory  = 2048
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
        ans.provisioning_path = "/vagrant/ansible"
        ans.playbook = "kmaster.yaml"
        ans.verbose = "-vvv"
      end

    end

  end


  # Kubernetes Worker Nodes
  WorkerCount = 1

  (1..WorkerCount).each do |i|

    config.vm.define "kworker#{i}" do |workernode|

      workernode.vm.box               = "generic/ubuntu2004"
      workernode.vm.box_check_update  = false
      workernode.vm.box_version       = "4.2.6"
      workernode.vm.hostname          = "kworker#{i}.lab.local"

      workernode.vm.network "private_network", bridge: "K8sLabSwitch"

      workernode.vm.provider :hyperv do |v|
        v.memory  = 1024
        v.maxmemory  = 2048
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

    end

  end

end
