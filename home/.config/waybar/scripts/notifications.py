#! /usr/bin/env python

'''
This is a utility for waybar for checking if notifications are mutes or now.

This script will return an 'alt' value to help select the right icon to
display.
'''

import json
import subprocess

def main():
    makoctl_result = subprocess.run(['makoctl', 'mode'], stdout=subprocess.PIPE)
    makoctl_result.check_returncode()
    modes = makoctl_result.stdout.decode('UTF-8').splitlines()

    mode = 'muted' if 'silent' in modes else 'unmuted'
    output = {
        'text': mode,
        'alt': mode,
    }
    print(json.dumps(output, indent=4))

if __name__ == '__main__':
    main()
