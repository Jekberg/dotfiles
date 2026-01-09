#!/usr/bin/env python3
#
# This script is intended to be used to configure the VIDEO_CARDS use expand
# flags in portage automatically.

import subprocess

detect_videocards_comm = ['scripts/gentoo/detect-videocards.sh']
generic_videocards = ['amdgpu', 'radeonsi', 'radeon', 'intel', 'nouveau', 'virgl']

def main():
    useflags = select_videocards_useflags()
    print(useflags)

def select_videocards_useflags():
    output = str()
    result = subprocess.run(detect_videocards_comm, capture_output=True)
    result.check_returncode()
    videocards = [videocard for videocard in result.stdout.decode('UTF-8').splitlines()] or generic_videocards

    lines = []
    lines.append(('*/*', '-* ' + ' '.join(videocards)))

    if 'radeonsi' in videocards and 'radeon' not in videocards:
        # When it updating with radeonsi set but not radeon, libdrm fails to
        # build. The solution seems to be to add the radeon videocard option.
        # From my understanding, readon is for ATI cards (pre-AMD). Work around
        # the issue by adding the radeon videocard for libdrm.
        lines.append(('x11-libs/libdrm', 'radeon'))


    # Each line is formatted to aling the flags, for this we need to find the
    # longest atom name.
    pad = max([len(line[0]) for line in lines])
    for line in lines:
        atom = line[0]
        flags = line[1]
        output += '{} VIDEO_CARDS: {}\n'.format(atom.ljust(pad), flags)

    return output

if __name__ == '__main__':
    main()
