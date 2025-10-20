#! /usr/bin/env python3
#
# This is a small utility for determening how many jobs are appropriate
# when invoking make and portage. This depends on the total amount of
# memory and the number of processors.

import re

gbyte_in_kbytes = 1000000

class Jobs:
    kbytes_per_job = 2 * gbyte_in_kbytes
    def __init__(self):
        self.sys_nproc = total_nproc()
        self.sys_kbytes = total_kbytes()
        self.max_nproc = int(self.sys_kbytes / Jobs.kbytes_per_job)

    def jobs_make(self):
        return min(self.sys_nproc, self.max_nproc)

    def jobs_emerge(self):
        return int(self.max_nproc / self.jobs_make())

    def lavg_make(self):
        return self.sys_nproc

    def lavg_emerge(self):
        return self.sys_nproc

def main():
    jobs = Jobs()
    print('JOBS_MAKE="{}"'.format(jobs.jobs_make()))
    print('JOBS_EMERGE="{}"'.format(jobs.jobs_emerge()))
    print('LAVG_MAKE="{}"'.format(jobs.lavg_make()))
    print('LAVG_EMERGE="{}"'.format(jobs.lavg_emerge()))

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
