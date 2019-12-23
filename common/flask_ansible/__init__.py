#!/usr/bin/env python3
# _*_ coding: utf-8 _*_

import json
import shutil
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
from ansible import context
import ansible.constants as C


class ResultCallback(CallbackBase):
    def v2_runner_on_ok(self, result, **kwargs):
        host = result._host
        print(json.dumps({host.name: result._result}, indent=4))


context.CLIARGS = ImmutableDict(connection='local', module_path=['/to/mymodules'], forks=10, become=None,
                                become_method=None, become_user=None, check=False, diff=False)
loader = DataLoader()
passwords = dict(vault_pass='secret')
results_callback = ResultCallback()
inventory = InventoryManager(loader=loader, sources='localhost,')
variable_manager = VariableManager(loader=loader, inventory=inventory)
play_source = dict(
    name = "Ansible Play",
    hosts = 'localhost',
    gather_facts = 'no',
    tasks = [
        dict(action=dict(module='shell', args='ifconfig'), register='shell_out'),
        dict(action=dict(module='debug', args=dict(msg='{{shell_out.stdout}}')))
     ]
)
play = Play().load(play_source, variable_manager=variable_manager, loader=loader)
tqm = None
try:
    tqm = TaskQueueManager(
        inventory=inventory,
        variable_manager=variable_manager,
        loader=loader,
        passwords=passwords,
        stdout_callback=results_callback
    )
    result = tqm.run(play)
finally:
    if tqm is not None:
        tqm.cleanup()
    shutil.rmtree(C.DEFAULT_LOCAL_TMP, True)
