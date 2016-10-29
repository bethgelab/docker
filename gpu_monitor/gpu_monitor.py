"""
Monitor GPU utilization and memory using TensorBoard.

Run this script as

>>> python3 gpu_monitor.py --log=gpu_logs --name=gpu9 --interval=300

to log the load. Ideally run this script in a Docker
container that has access to all GPUs.
"""
import shutil, socket, subprocess, sys, time, os
import tensorflow as tf

def log_gpu(logdir, name, interval):
    def get_utilization():
        cmd = ['nvidia-smi', '--query-gpu=utilization.gpu', '--format=csv,noheader,nounits']
        gpu_util = subprocess.check_output(cmd).strip()
        gpu_util = gpu_util.split(b'\n')
        gpu_util = list(map(int, gpu_util))
        return gpu_util
    
    def time_since_2am():
        import datetime
        now = datetime.datetime.now()
        midnight = now.replace(hour=22, minute=0, second=0, microsecond=0)
        return (now - midnight).seconds
    
    def init_session():
        g = tf.Graph()
        sess = tf.InteractiveSession(graph=g)
        
        with g.as_default():
            # initialize summary writer
            gpu_util_placeholders = []
            for gpu in range(no_gpus):
                load = tf.placeholder(tf.float32)
                tf.scalar_summary(name+'/gpu'+str(gpu), load)
                gpu_util_placeholders.append(load)

            # merge summaries
            merged = tf.merge_all_summaries()
            writer = tf.train.SummaryWriter(logdir)

        # initialize session
        tf.initialize_all_variables().run()
        
        # at initialization set y-range between 0 and 100%
        for util in [0, 100]:
            gpu_util = dict([(gpu_util_placeholders[k], util) for k in range(no_gpus)])
            summary = sess.run(merged, feed_dict=gpu_util)
            writer.add_summary(summary, 0)
    
        return sess, gpu_util_placeholders, merged, writer
    
    # test number of available GPUs
    no_gpus = len(get_utilization())
    logdir  = os.path.join(logdir, name)
    
    step = 1
    sess, gpu_util_placeholders, merged, writer = init_session()
    
    # infinite loop to log (with timeout)
    while True:
        gpu_util = get_utilization()
        gpu_util = dict([(gpu_util_placeholders[k], u) for k, u in enumerate(gpu_util)])
         
        print("utilization: ", gpu_util)
        
        # log values
        summary = sess.run(merged, feed_dict=gpu_util)
        writer.add_summary(summary, step)
        step += 1
        
        time.sleep(interval)
        print("time: ", float(time_since_2am()))        

        if time_since_2am() < 1.1*interval:
            print('RESTART')
            
            # delete records in logdir
            shutil.rmtree(logdir+'/')
            os.makedirs(logdir+'/')
            
            step = 0
            
            sess.close()
            sess, gpu_util_placeholders, merged, writer = init_session()
            
if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Command line options')
    parser.add_argument('--log', type=str, dest='logdir')
    parser.add_argument('--name', type=str, dest='name')
    parser.add_argument('--interval', type=int, dest='interval')
    args = parser.parse_args(sys.argv[1:])
    print("Trying to log gpu")
    log_gpu(**{k:v for (k,v) in vars(args).items() if v is not None})
