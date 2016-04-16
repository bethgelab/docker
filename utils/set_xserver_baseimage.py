import sys
import os

tags = sys.argv[1].split(' ')
images = sys.argv[2].split(' ')

print os.getcwd()

def replace_line(file_name, line_num, text):
    lines = open(file_name, 'r').readlines()
    lines[line_num] = text + "\n"
    out = open(file_name, 'w')
    out.writelines(lines)
    out.close()

for i in xrange(len(tags)):
    replace_line('docker-xserver/' + tags[i] + '/Dockerfile', 0, 'FROM ' + images[i])
