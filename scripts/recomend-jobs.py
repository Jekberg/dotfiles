#! /usr/bin/python3
#
# This is a small utility for determening how many jobs are appropriate
# when invoking make and portage. This depends on the total amount of
# memory and the number of processors.

import re

gbyte_in_kbytes = 1000000

def main():
    kbytes_per_job = 2 * gbyte_in_kbytes
    nproc = total_nproc()
    kbytes = total_kbytes()

    max_nproc = int(kbytes / kbytes_per_job)
    make_nproc = min(nproc, max_nproc)
    portage_nproc = int(max_nproc / make_nproc)

    print('MAKE={}'.format(make_nproc))
    print('PORTAGE={}'.format(portage_nproc))

def total_nproc():
    nproc = 0
    with open('/proc/cpuinfo', 'r') as cpuinfo:
        for line in cpuinfo:
            match = re.match(r'processor\s*:\s*\d+', line)
            if match:
                nproc += 1

    if nproc == 0:
        raise Exception('Unable to find number of processors')
    return nproc

def total_kbytes():
    with open('/proc/meminfo', 'r') as meminfo:
        for line in meminfo:
            match = re.match(r'MemTotal:\s*(?P<mkbytes>\d+)\s*kB', line)
            if match:
                return int(match['mkbytes'])

    raise Exception('Unable to find total memory')

if __name__ == '__main__':
    main()
