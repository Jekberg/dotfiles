#! /usr/bin/env python3

'''
Get the GPU usage.

This only currently works with AMD GPUs. I have tested it on a system with an
RX 7900 XTX, older cards may not work. Likewise, this may not work for systems
with multiple GPUs. Or requires some tweaking.
'''

import json
import re
import subprocess

def main():
    radeontop_comm = ['radeontop', '--dump', '-', '--limit', '1']
    radeontop_result = subprocess.run(radeontop_comm, stdout=subprocess.PIPE)
    radeontop_result.check_returncode()

    # I like nvtop, but it does not seem to let me query the gpu stats so
    # easily compared to radeontop.
    #
    # radeontop seem to not recognise my RX 7900 XTX. So it emits some messages
    # to stdout (instead of stderr).
    #
    # Roughly parse the output of radeontop to find the specific information
    # we are interested in.
    gpustats = radeontop_result.stdout.decode('UTF-8')
    gpu_match = re.search(r'gpu (?P<gpu_percent>\d+\.\d+)%', gpustats)

    vram_match = re.search(r'vram (?P<vram_percent>\d+\.\d+)%', gpustats)
    mclk_match = re.search(r'mclk (?P<mclk_percent>\d+\.\d+)%', gpustats)
    sclk_match = re.search(r'sclk (?P<sclk_percent>\d+\.\d+)%', gpustats)

    gpu_busy_percent = int(round(float(gpu_match['gpu_percent'])))
    gpu_vram_percent = int(round(float(vram_match['vram_percent'])))
    gpu_mclk_percent = int(round(float(mclk_match['mclk_percent'])))
    gpu_sclk_percent = int(round(float(sclk_match['sclk_percent'])))

    output = {
        'text': gpu_busy_percent,
        'tooltip' : '\n'.join([
            'busy {}%'.format(gpu_busy_percent),
            'vram {}%'.format(gpu_vram_percent),
            'sclk {}%'.format(gpu_sclk_percent),
            'mclk {}%'.format(gpu_mclk_percent)
            ])
    }
    print(json.dumps(output, indent=4))

if __name__ == '__main__':
    main()
