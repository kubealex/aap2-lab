# Red Hat AAP2 Demo env installer

This is a simple demo environment provisioner for AAP2 to install.
It creates:

- libvirt-network with DHCP/DNS
- libvirt-pool for your VM
- AAP2 controller

## Host setup

### Download Terraform

VM setup is based on Terraform, it instantiates two virtual machines, *controller* and *hub* kickstarting the setup.

First you need to download and install Terraform:

    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform

### Install Ansible

You need to follow the instructions in [Ansible Website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package) to proceed and install Ansible on your machine.

## Needed variables

In order to work, the playbooks need some basic variables:

| Variable | Value | Description | 
|--|--|--|
| **network_cidr** | Defaults to 192.168.216.0/24 | The subnet that is assigned to libvirt network |
| **offline_token** | No default | [Offline Token](https://access.redhat.com/management/api) for images/packages download from Red Hat Portal |
| **rhsm_user** | No default | The Red Hat Account username |
| **rhsm_password** | No default | The Red Hat Account username |
| **rhsm_pool_id** | No default | The pool ID of the subscription covering the product [in subscription manager](https://access.redhat.com/management/subscriptions/) |

## Lab provisioning

The provisioner consists of two playbooks, that configure the underlying components (VM, network) and prepares the guests to install AAP2.

The first playbook is **provision-lab.yml** which takes care of creating KVM resources. It only has a single variable: 

| Variable | Value |
|--|--|
| **network_cidr** | Defaults to 192.168.216.0/24 |

The package comes with an inventory:

    localhost ansible_connection=local

    [controller]
    controller.aapdemo.labs ansible_user=sysadmin ansible_ssh_pass=redhat ansible_ssh_common_args='-o StrictHostKeyChecking=no'

    [hub]
    hub.aapdemo.labs ansible_user=sysadmin ansible_ssh_pass=redhat ansible_ssh_common_args='-o StrictHostKeyChecking=no'

The playbook can either download RHEL 9 image, or work with pre-downloaded images. If you choose not to download it, the only requirement is providing the image in the playbook directory with the name **rhel.iso**.

**IMPORTANT** If you don't want to download images (it's around 20GB), just leave the **offline_token** blank.

Since some modules rely on additional collections you will need to install them via:

    ansible-galaxy install -r requirements.yml

Review settings in **provision-lab.yml** file, containing some basic inputs:

    network_cidr = ["192.168.216.0/24"]

The terraform plan also creates an isolated virtual network, with DHCP and DNS for the specified domain.

Once you set the *network_cidr* variable to the desired value, you can run the playbook:

    ansible-playbook -i inventory provision-lab.yml

The setup will take a bit as it is a full install with a kickstarter. 

## AAP2 setup

With your lab up and running, you can proceed installing AAP2 using the provided **aap2-setup.yml** playbook.

    ansible-playbook -i inventory aap2-setup.yml

## Test your configuration

If the setup was good, you will be able to access your AAP2 instances on [](https://controller.aapdemo.labs) and [](https://hub.aapdemo.labs)