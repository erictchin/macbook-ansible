
provision:
	ansible-playbook -vvv playbooks/provision.yml --ask-become-pass --extra-vars=@vars/config.yml

defaults:
	ansible-playbook -vvv playbooks/defaults.yml --ask-become-pass --extra-vars=@vars/config.yml

security:
	ansible-playbook -vvv playbooks/security.yml --ask-become-pass
