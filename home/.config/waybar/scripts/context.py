#!/usr/bin/env python3
#
# This script continiously prints contextual infomation to waybar.
#
# The intentinos is to mix functionality similar to that found in other waybar
# modules such as hyprland/window or hyprland/submap. The output depends on the
# current state of the system e.g. if a submap is active it takes precedence
# over window (or other information). This should help to minimise information.

__author__ = 'John Berg'

import json
import os
import select
import socket
import sys

def main():
    hyprland = Hyprland()
    order = [
                current_submap,
                current_window,
                current_workspace
            ]

    epoll = select.epoll()
    epoll.register(hyprland.socket_fd(), select.EPOLLIN)

    while True:
        output = None
        for fn in order:
            output = fn()
            if output is not None:
                break

        if output is not None:
            print(json.dumps(output))
            sys.stdout.flush()

        # Wait for the next event
        #
        # Right now, we don't actually consume the event, we just use this to
        # detect if there has been any state changes.
        epoll.poll()
        hyprland.fetch_events()

class Hyprland:
    '''
    This class is a wrapper for interacting with Hyprland via IPC. 
    '''

    instance = os.getenv('HYPRLAND_INSTANCE_SIGNATURE')
    runtime_dir = os.path.join(os.getenv('XDG_RUNTIME_DIR'), 'hypr', instance)
    socket_path = os.path.join(runtime_dir, '.socket.sock')
    socket2_path = os.path.join(runtime_dir, '.socket2.sock')

    def __init__(self):
        self._socket2 = socket.socket(socket.AF_UNIX)
        self._socket2.connect(Hyprland.socket2_path)

    def __del__(self):
        self._socket2.close()

    def fetch_events(self) -> str:
        buffer = bytes()
        while not buffer or buffer[-1] != ord('\n'):
            result = self._socket2.recv(1024)
            if len(result) == 0:
                break # This seems like an unexpected exit
            buffer += result

        return buffer.decode('UTF-8')

    def socket_fd(self):
        return self._socket2.fileno()

    def command(cmd: str) -> str:
        buffer = bytes()
        with socket.socket(socket.AF_UNIX) as sock:
            sock.connect(Hyprland.socket_path)
            sock.send(cmd.encode())

            while True:
                result = sock.recv(1024)
                if len(result) == 0:
                    break
                buffer += result
        return buffer.decode('UTF-8')

def current_submap() -> dict:
    # The j/ flag should give us back JSON, but the python json parser does not
    # accept it. But it is trivial to parse the raw submap output.
    submap = Hyprland.command('/submap')
    if submap is None:
        return None # Unlikely but just in case

    submap = submap.strip()
    if submap == 'default':
        return None # Don't show the default submap
    return {
            'text': '<b>-- {} --</b>'.format(submap),
            'alt': 'submap',
            'tooltip': 'todo',
            'class': 'submap'
            }

def current_window() -> dict:
    # The activeworkspace seems better for reporting the active window than
    # activewindow. Specifically, activewindow seems to latch on the the last
    # active window. Whereas the activeworkspace lastactivewindow does not...
    result = Hyprland.command('j/activeworkspace')
    json_obj = json.loads(result)
    title = json_obj['lastwindowtitle'] if 'lastwindowtitle' in json_obj else None
    if title is None:
        return None
    if title == '':
        return None # Don't show, not intetesting
    return {
            'text': title,
            'alt': 'window',
            'tooltip': 'todo',
            'class': 'window'
            }

def current_workspace() -> dict:
    result = Hyprland.command('j/activeworkspace')
    json_obj = json.loads(result)
    name = json_obj['name'] if 'name' in json_obj else None
    if name is None:
        return None

    return {
            'text': '<i>workspace {}</i>'.format(name),
            'alt': 'workspace',
            'tooltip': 'todo',
            'class': 'workspace'
            }

if __name__ == '__main__':
    main()
