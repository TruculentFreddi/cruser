**Configure inventory.ini and vars.yml before run!**

**First run(init):**

_ansible-playbook -i inventory.ini setup_cluster.yaml --user root --ask-vault-pass_

**Second run**

_ansible-playbook -i inventory.ini setup_cluster.yaml --user root --skip-tags=init_token --ask-vault-pass_



`Ansible-vault password in settings->ci/cd->Variables`
