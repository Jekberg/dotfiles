#! /usr/bin/env python3

'''
Fetch the current weather report for displaying in waybar.
'''

import requests
import json
import time

def main():
    max_attempts = 10
    attempt = 0
    while True:
        try:
            output = {
                'text': fetch_report(1).strip(),
                'tooltip': fetch_report(4).strip()
            }
            print(json.dumps(output, indent=4))
            break
        except Exception as e:
            attempt += 1
            if attempt > max_attempts:
                raise e
            time.sleep(2 * attempt)
def fetch_report(format):
    assert type(format) == int
    url = 'https://wttr.in/?format={}'.format(format)
    response = requests.get(url)
    response.raise_for_status()
    return response.text

if __name__ == '__main__':
    main()
