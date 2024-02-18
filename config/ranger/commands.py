from __future__ import (absolute_import, division, print_function)
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

    def tab(self,tabnum):
        return self._tab_directory_content()

class move_recent_downloads(Command):
    ''':move_recent_downloads
    Move the most recent download to the current directory
    '''
    def execute(self):
        import glob
        import os
        path = self.fm.thisdir.path
        list_of_files = glob.glob('/home/adam/downloads/*')
        latest_file = max(list_of_files, key=os.path.getctime)
        while 'STG-backups' in latest_file:
            list_of_files.remove(latest_file)
            latest_file = max(list_of_files, key=os.path.getctime)

        self.fm.execute_console(f'shell mv "{latest_file}" "{path}"')
        self.fm.notify(f'Moved {latest_file} to the current directory')

class sparesnack_workspace(Command):
    ''':sparesnack_workspace
    - Opens vim with the Django session and git version control
    '''

    def execute(self):
        self.fm.execute_console('set vcs_aware true')
        self.fm.execute_console('shell nvim -c ":SLoad SpareSnack"')

class goread_workspace(Command):
    ''':goread_workspace
    - Opens vim with the goread session and git version control
    '''

    def execute(self):
        self.fm.execute_console('set vcs_aware true')
        self.fm.execute_console('shell nvim -c ":SLoad goread"')

class gogist_workspace(Command):
    ''':gogist_workspace
    - Opens vim with the gogist session and git version control
    '''

    def execute(self):
        self.fm.execute_console('set vcs_aware true')
        self.fm.execute_console('shell nvim -c ":SLoad gogist"')


class gopoker_workspace(Command):
    ''':gopoker_workspace
    - Opens vim with the gopoker session and git version control
    '''

    def execute(self):
        self.fm.execute_console('set vcs_aware true')
        self.fm.execute_console('shell nvim -c ":SLoad gopoker"')


class gopoker_unsecure_workspace(Command):
    ''':gopoker_unsecure_workspace
    - Opens vim with the gopoker session and git version control
    '''

    def execute(self):
        self.fm.execute_console('set vcs_aware true')
        self.fm.execute_console('shell nvim -c ":SLoad gopoker_unsecure"')


class my_quit(Command):
    """:my_quit
    - Saves the ranger cwd to a file called /tmp/mycwd
    """

    def execute(self):
        self.fm.execute_console('shell echo "'+self.fm.thisdir.path+'" > /tmp/mycwd')
        self.fm.execute_console('quit')
