# macbook

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
# Create your config.
# Edit `vars/config.yml` with your favorite editor.  Check the list of applications to be installed.
cp vars/config.yml.sample vars/config.yml

# Provision
# This will provision MacOS and configure better defaults
ansible-playbook -vvv playbooks/provision.yml --ask-become-pass --extra-vars=@vars/config.yml

# Security
# This will configure extra security features of MacOS
ansible-playbook -vvv playbooks/security.yml --ask-become-pass
```

## Extras

* To configure *just* system defaults

```bash
ansible-playbook -vvv playbooks/defaults.yml --ask-become-pass --extra-vars=@vars/config.yml
```

## Notes

* MacOS hardening according to CIS. The security playbook will apply a custom configuration of security-related OS configuration.  Its core is based off of [CIS for macOS Sierra](https://github.com/jamfprofessionalservices/CIS-for-macOS-Sierra-CP).