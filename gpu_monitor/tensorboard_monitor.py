"""
Script that controls Tensorboard to monitor logs.

Run this script as

>>> python3 tensorboard_monitor.py --log=gpu_logs

to visualise GPU utilization. In particular, this script kills and
restarts Tensorboard at 2am every day.
"""

import subprocess, sys
import time

def manage_board(logdir):
    def time_since_2am():
        import datetime
        now = datetime.datetime.now()
        midnight = now.replace(hour=22, minute=0, second=0, microsecond=0)
        return (now - midnight).seconds
    
    # start tensorboard
    proc = subprocess.Popen(["tensorboard", "--logdir", logdir], shell=False)
    
    while True:
        time.sleep(60)
        print(time_since_2am())        

        if time_since_2am() < 65:
            subprocess.call(["kill", "-9", "%d" % proc.pid])
            proc.wait()
            proc = subprocess.Popen(["tensorboard", "--logdir", logdir], shell=False)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Command line options')
    parser.add_argument('--log', type=str, dest='logdir')
    args = parser.parse_args(sys.argv[1:])
    manage_board(**{k:v for (k,v) in vars(args).items() if v is not None})
