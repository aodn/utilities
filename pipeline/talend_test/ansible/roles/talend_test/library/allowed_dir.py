
import os

from ansible.module_utils.basic import AnsibleModule


def prep_dir(dir_or_file):
    if '.' in os.path.basename(dir_or_file):
        return os.path.dirname(dir_or_file)
    else:
        return os.path.dirname(dir_or_file)


def run_module():

    module_args = dict(
        allowed_dirs=dict(type='list', required=True),
        test=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    p = type('Params', (), module.params)

    test = prep_dir(p.test)

    found = []

    for allowed_dir in p.allowed_dirs:
        if test == allowed_dir.rstrip('/'):
            found.append(allowed_dir)

    if len(found) > 0:
        module.exit_json(changed=False)

    module.fail_json(msg="directory not in allowed directories")


def main():
    run_module()


if __name__ == '__main__':
    main()
