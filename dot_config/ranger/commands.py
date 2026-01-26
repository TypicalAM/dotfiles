from __future__ import (absolute_import, division, print_function)
import os
import glob
from ranger.api.commands import Command


class nvim(Command):
    """:nvim
    Open or create the file in neovim
    """

    def execute(self):
        from os.path import expanduser, join
        mypath = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if expanduser(self.rest(1)):
            self.fm.execute_console('shell nvim "'+mypath+'"')
        else:
            self.fm.execute_console('shell nvim ')
        self.fm.notify('Closed neovim')

    def tab(self, tabnum):
        return self._tab_directory_content()


class xdg(Command):
    """:xdg
    Open or create the file with xdg-open
    """

    def execute(self):
        from os.path import expanduser, join
        mypath = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if expanduser(self.rest(1)):
            self.fm.execute_console('shell xdg-open "'+mypath+'"')
        else:
            self.fm.execute_console('shell xdg-open ')
        self.fm.notify('Closed app')

    def tab(self, tabnum):
        return self._tab_directory_content()


class move_recent_downloads(Command):
    ''':move_recent_downloads
    Move the most recent download to the current directory
    '''

    def execute(self):
        path = self.fm.thisdir.path
        list_of_files = glob.glob('/home/adam/downloads/*')
        latest_file = max(list_of_files, key=os.path.getctime)
        while 'STG-backups' in latest_file:
            list_of_files.remove(latest_file)
            latest_file = max(list_of_files, key=os.path.getctime)

        self.fm.execute_console(f'shell mv "{latest_file}" "{path}"')
        self.fm.notify(f'Moved {latest_file} to the current directory')
