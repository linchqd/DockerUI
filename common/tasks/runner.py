#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import json
import os
import shutil
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.inventory.host import Host
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
from ansible.plugins.callback.default import CallbackModule
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible import context
import ansible.constants as C
from ansible.errors import AnsibleError


class ResultCallback(CallbackBase):
    """
       重写callbackBase类的部分方法
       """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.host_ok = {}
        self.host_unreachable = {}
        self.host_failed = {}

    def v2_runner_on_unreachable(self, result):
        self.host_unreachable[result._host.get_name()] = result

    def v2_runner_on_ok(self, result, **kwargs):
        self.host_ok[result._host.get_name()] = result

    def v2_runner_on_failed(self, result, **kwargs):
        self.host_failed[result._host.get_name()] = result

    def v2_playbook_on_stats(self, stats):
        super().__init__(stats)


class AnsHost(Host):
    """
    :param host_info:
    {
        "ip": '',
        "port": int,
        "username": "",
        "password": "",
        "private_key": "",
        "groups": [{"name": "test", "vars": {"var": "test"}}],
        "vars": {"var": "test"}
    }
    """

    def __init__(self, host_info):
        self.host_info = host_info
        self.name = host_info.get('ip')
        self.port = host_info.get('port') or 22
        super().__init__(self.name, self.port)
        self.set_ssh_info()

    def set_ssh_info(self):
        self.set_variable('ansible_ssh_host', self.host_info.get('ip'))
        self.set_variable('ansible_ssh_port', self.host_info.get('port', 22))
        self.set_variable('ansible_ssh_user', self.host_info.get('username', 'root'))

        if self.host_info.get('password'):
            self.set_variable('ansible_ssh_pass', self.host_info.get('password'))

        if self.host_info.get('private_key'):
            self.set_variable('ansible_ssh_private_key_file', self.host_info.get('private_key'))

        self.set_extra_variable()

    def set_extra_variable(self):
        for k, v in self.host_info.get('vars', {}).items():
            self.set_variable(k, v)

    def __repr__(self):
        return self.name


class AnsInventory(InventoryManager):
    """
        :param host_list:
        [{
            "ip": '',
            "port": int,
            "username": "",
            "password": "",
            "private_key": "",
            "groups": [{"name": "test", "vars": {"var": "test"}}],
            "vars": {"var": "test"},
        }]
        """

    def __init__(self, host_list=None):
        self.loader = DataLoader()
        if host_list is None:
            self.host_list = []
        elif isinstance(host_list, list):
            self.host_list = host_list
        else:
            raise TypeError("host list must be a list")
        super().__init__(self.loader)

    def parse_sources(self, cache=False):
        all_group = self._inventory.groups.get('all')

        for host_info in self.host_list:
            host = AnsHost(host_info=host_info)
            self._inventory.hosts[host.name] = host

            groups = host_info.get('groups')
            if groups and isinstance(groups, list):
                for g in groups:
                    assert isinstance(g, dict)
                    assert isinstance(g.get('name', None), str)
                    group = self._inventory.groups.get(g['name'], None)
                    if group is None:
                        self.add_group(g.get('name'))
                        group = self._inventory.groups.get(g['name'])
                        all_group.add_child_group(group)
                    group.add_host(host)
            else:
                all_group.add_host(host)


class BaseRunner(object):
    def __init__(self,
                 connection='smart',
                 remote_user=None,
                 ack_pass=None,
                 sudo=None,
                 sudo_user=None,
                 ask_sudo_pass=None,
                 module_path=None,
                 become=None,
                 become_method=None,
                 become_user=None,
                 check=False,
                 diff=False,
                 forks=10,
                 timeout=60,
                 private_key_file=None,
                 verbosity=3,
                 listhosts=None,
                 listtasks=None,
                 listtags=None,
                 syntax=None,
                 start_at_task=None
                 ):

        context.CLIARGS = ImmutableDict(
            connection=connection,
            remote_user=remote_user,
            ack_pass=ack_pass,
            sudo=sudo,
            sudo_user=sudo_user,
            ask_sudo_pass=ask_sudo_pass,
            module_path=module_path,
            become=become,
            become_method=become_method,
            become_user=become_user,
            check=check,
            diff=diff,
            forks=forks,
            timeout=timeout,
            private_key_file=private_key_file,
            verbosity=verbosity,
            listhosts=listhosts,
            listtasks=listtasks,
            listtags=listtags,
            syntax=syntax,
            start_at_task=start_at_task,
        )


class AdHocRunner(BaseRunner):

    def __init__(self, inventory, *args, **kwargs):

        super().__init__(*args, **kwargs)

        # 实例化数据解析器
        self.loader = DataLoader()

        self.inventory = inventory
        # 设置密码，可以为空字典，但必须有此参数
        self.passwords = {}

        # 实例化回调插件对象
        self.results_callback = ResultCallback()

        # 变量管理器
        self.variable_manager = VariableManager(self.loader, self.inventory)

    def check_hosts_pattern(self, pattern):
        if not pattern:
            raise AnsibleError("Pattern '{}' is not valid!".format(pattern))
        if not self.inventory.list_hosts("all"):
            raise AnsibleError("Inventory is empty.")
        if not self.inventory.list_hosts(pattern):
            raise AnsibleError("pattern: %s  dose not match any hosts." % pattern)

    @staticmethod
    def check_module_args(module_name, module_args=''):
        if module_name in C.MODULE_REQUIRE_ARGS and not module_args:
            err = "No argument passed to '%s' module." % module_name
            raise AnsibleError(err)

    def add_tasks(self, _tasks):
        task_list = []
        for task in _tasks:
            self.check_module_args(task['action']['module'], task['action'].get('args'))
            task_list.append(task)
        return task_list

    def run(self, tasks, pattern, play_name='Ansible AdHoc Runner', gather_facts='no'):
        """
        :param tasks: [{'action': {'module': 'command', 'args': 'ls'}, ...}, ]
        :param pattern: all, *, or others
        :param play_name: The play name
        :param gather_facts, default no
        :return:
        """

        self.check_hosts_pattern(pattern)

        task_list = self.add_tasks(tasks)

        play_source = dict(
            name=play_name,
            hosts=pattern,
            gather_facts=gather_facts,
            tasks=task_list
        )

        play = Play().load(play_source, variable_manager=self.variable_manager, loader=self.loader)

        tqm = None
        try:
            tqm = TaskQueueManager(
                inventory=self.inventory,
                variable_manager=self.variable_manager,
                loader=self.loader,
                passwords=self.passwords,
                stdout_callback=self.results_callback
            )
            tqm.run(play)
            for host, result in self.results_callback.host_failed.items():
                print("主机{}, 执行结果{}".format(host, result._result))
        finally:
            if tqm is not None:
                tqm.cleanup()
            shutil.rmtree(C.DEFAULT_LOCAL_TMP, True)

    def playbook(self, playbooks):
        from ansible.executor.playbook_executor import PlaybookExecutor

        playbook = PlaybookExecutor(playbooks=playbooks,  # 注意这里是一个列表
                                    inventory=self.inventory,
                                    variable_manager=self.variable_manager,
                                    loader=self.loader,
                                    passwords=self.passwords)

        # 使用回调函数
        playbook._tqm._stdout_callback = self.results_callback

        result = playbook.run()

    def get_result(self):
        result_raw = {'success': {}, 'failed': {}, 'unreachable': {}}

        # print(self.results_callback.host_ok)
        for host, result in self.results_callback.host_ok.items():
            result_raw['success'][host] = result._result
        for host, result in self.results_callback.host_failed.items():
            result_raw['failed'][host] = result._result
        for host, result in self.results_callback.host_unreachable.items():
            result_raw['unreachable'][host] = result._result

        # 最终打印结果，并且使用 JSON 继续格式化
        print(json.dumps(result_raw, indent=4))


class PlayBookRunner(BaseRunner):

    def __init__(self, playbook, inventory, *args, **kwargs):

        super().__init__(*args, **kwargs)
        self.playbook = playbook
        if not self.playbook or not os.path.exists(self.playbook):
            raise AnsibleError("playbook '{}' is Not Found".format(self.playbook))
        self.inventory = inventory
        if not self.inventory.list_hosts('all'):
            raise AnsibleError("Inventory is Empty")
        self.loader = DataLoader()
        self.results_callback = ResultCallback()
        self.playbook = playbook
        self.variable_manager = VariableManager(self.loader, self.inventory)
        self.passwords = {}

    def run(self):

        playbook_executor = PlaybookExecutor(
            playbooks=[self.playbook],
            inventory=self.inventory,
            variable_manager=self.variable_manager,
            loader=self.loader,
            passwords=self.passwords
        )

        playbook_executor._tqm._stdout_callback = self.results_callback

        playbook_executor.run()
        playbook_executor._tqm.cleanup()
        self.get_result()

    def get_result(self):
        pass
        # result_raw = {'success': {}, 'failed': {}, 'unreachable': {}}
        #
        # # print(self.results_callback.host_ok)
        # for host, result in self.results_callback.host_ok.items():
        #     result_raw['success'][host] = result._result
        # for host, result in self.results_callback.host_failed.items():
        #     result_raw['failed'][host] = result._result
        # for host, result in self.results_callback.host_unreachable.items():
        #     result_raw['unreachable'][host] = result._result
        #
        # # 最终打印结果，并且使用 JSON 继续格式化
        # print(json.dumps(result_raw, indent=4))


if __name__ == '__main__':

    hosts = [{
        "ip": '192.168.10.20',
        "port": 22,
        "username": "root",
        "password": "linchqd930520",
        "private_key": "",
        "groups": [{"name": "test", "vars": {"var": "test"}}],
        "vars": {"var": "test"},
    }]
    inv = AnsInventory(host_list=hosts)
    # runner = AdHocRunner(inventory=inv)

    # t = [
    #     {"action": {"module": "shell", "args": "ifconfig"}, "name": "teesttttek"},
    #     {"action": {"module": "shell", "args": "whomi"}, "name": "run_whoami"}
    # ]

    # runner.run(tasks=t, pattern='all', play_name='test for runner')
    PlayBookRunner(
        playbook='/Users/linchqd/Desktop/dockerui/api/common/tasks/ansible_play/add-sshkey.yml',
        inventory=inv
    ).run()

