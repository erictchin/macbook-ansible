# laptop

## Initial configuration

```bash
# Clone the repo
git clone git@github.com:erictchin/macbook.git
cd macbook

# Install XCode CLI, pip, and upstream ansible
./bootstrap.sh
```

## Create your `config`

```bash
cp vars/config.yml.sample vars/config.yml
```

And edit `vars/config.yml` with your favorite editor.  Check the list of applications to be installed.

## Provision

```bash
# Run the playbook to provision and configure defaults
ansible-playbook -vvv playbooks/provision.yml --ask-become-pass --extra-vars=@vars/config.yml
```

## Extras

* To configure *just* system defaults

```bash
ansible-playbook -vvv playbooks/defaults.yml --ask-become-pass --extra-vars=@vars/config.yml
```

* (WIP) Some OS hardening according to CIS

```bash
ansible-playbook -vvv playbooks/security.yml --ask-become-pass
```

Note: security playbook will apply a custom configuration of security-related OS configuration.  Its core is based off of [CIS for macOS Sierra](https://github.com/jamfprofessionalservices/CIS-for-macOS-Sierra-CP).
