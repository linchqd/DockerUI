#!/usr/local/bin/python3
# _*_ coding: utf-8 _*_


import json
import shutil
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.inventory.group import Group
from ansible.inventory.host import Host
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
from ansible import context
import ansible.constants as C
import os


class ResultCallback(CallbackBase):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.host_ok = {}
        self.host_unreachable = {}
        self.host_failed = {}
        self.task_ok = {}

    def v2_runner_on_unreachable(self, result):
        self.host_unreachable[result._host.get_name()] = result

    def v2_runner_on_ok(self, result, **kwargs):
        self.host_ok[result._host.get_name()] = result

    def v2_runner_on_failed(self, result, **kwargs):
        self.host_failed[result._host.get_name()] = result


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

        # 实例化数据解析器
        self.loader = DataLoader()

        # 设置密码，可以为空字典，但必须有此参数
        self.passwords = {}

        # 实例化回调插件对象
        self.results_callback = ResultCallback()

        # 变量管理器
        self.variable_manager = VariableManager(self.loader, self.inventory)

    def run(self, hosts='localhost', gether_facts="no", module="ping", args=''):
        play_source = dict(
            name="Ad-hoc",
            hosts=hosts,
            gather_facts=gether_facts,
            tasks=[
                # 这里每个 task 就是这个列表中的一个元素，格式是嵌套的字典
                # 也可以作为参数传递过来，这里就简单化了。
                {"action": {"module": module, "args": args}},
            ])

        play = Play().load(play_source, variable_manager=self.variable_manager, loader=self.loader)

        tqm = None
        try:
            tqm = TaskQueueManager(
                inventory=self.inventory,
                variable_manager=self.variable_manager,
                loader=self.loader,
                passwords=self.passwords,
                stdout_callback=self.results_callback)

            result = tqm.run(play)
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


if __name__ == '__main__':

    # ansible2 = MyAnsiable2(inventory='/tmp/hosts', connection='smart')
    #
    # ansible2.playbook(playbooks=['/tmp/exec-command.yml'])
    #
    # ansible2.get_result()

    res = [
        {
            "ip": '10.0.2.15',
            "port": 22,
            "username": "root",
            "vars": {"ansible_ssh_private_key_file": "~/.pkey"}
        }
    ]
    inv = AnsInventory(host_list=res)
    ansible2 = MyAnsiable2(inventory=inv, connection='smart')
    ansible2.playbook(playbooks=['/home/test/pyweb/api/common/tasks/ansible_play/add-sshkey.yml'])
    ansible2.get_result()

