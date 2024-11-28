#! /usr/bin/env python3

'''
This script is intended to run on Arch Linux to check for available updates.

It will give a summary of the number of packages which have updates. And also
provides a complete list as a tooltip.
'''

import json
import subprocess

def main():
    checkupdates_result = subprocess.run(['checkupdates'],
                                         stdout=subprocess.PIPE)
    try:
        checkupdates_result.check_returncode()

        pending_updates = checkupdates_result.stdout.decode('UTF-8')
        nr_pending_updates = len(pending_updates.splitlines())
        output = {
            'text'   : nr_pending_updates,
            'tooltip': pending_updates,
            'class'  : 'pending-updates' if nr_pending_updates else 'no-updates'
        }
        print(json.dumps(output, indent=4))
    except Exception as e:
        if checkupdates_result.returncode != 2:
            # checkupdates will inidcate that there are no updates available by
            # by returning an error code of 2. So anything else, we consider a
            # failure.
            raise e
        output = {
            'text'   : 0,
            'tooltip': 'No updates',
            'class'  : 'no-updates'
        }
        print(json.dumps(output, indent=4))

if __name__ == '__main__':
    main()
