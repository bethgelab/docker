# Restart board and minions
restart:
	make remove-all-minions
	make remove-board
	make remove-logs
	make start-board
	make start-all-minions

start:
	make start-board
	make start-all-minions

# Starts tensorboard to visualise GPU usage since 2am every day
start-board:
	ssh gpu9 "source /etc/profile && cd $(shell pwd) && \
	docker build -t bethgelab/gpu_monitor_headnode docker/ && \
	../agmb-docker-test run -p 7000:6006 -p 700:8888 --name gpu_monitor_headnode -d bethgelab/gpu_monitor_headnode && \
	docker exec gpu_monitor_headnode /bin/sh -c 'nohup python3 $(shell pwd)/tensorboard_monitor.py --log=$(shell pwd)/logs/ > /dev/null 2>&1 &'"

remove-logs:	
	-ssh gpu9 "source /etc/profile && cd $(shell pwd) && \
	docker build -t bethgelab/gpu_monitor_headnode docker/ && \
	../agmb-docker-test run --name remove_logs -d bethgelab/gpu_monitor_headnode && \
	docker exec remove_logs /bin/sh -c 'rm -r $(shell pwd)/logs/*'"
	-ssh gpu9 "docker rm -f remove_logs"

remove-board:
	- ssh gpu9 "docker rm -f gpu_monitor_headnode"
  
restart-board:
	make remove-board
	make start-board

# Starts a minion (monitoring GPU usage) on a given node
#
# parameters:
# - required: node, gpus
start-minion:
	ssh $(node) "source /etc/profile && cd $(shell pwd) && \
	docker ps && \
        docker build -t bethgelab/gpu_minion docker/ && \
        GPU=$(gpus) ../agmb-docker-test run -p 701:8888 --name gpu_minion -d bethgelab/gpu_minion && \
        docker exec -i gpu_minion /bin/bash -c 'nohup python3 $(shell pwd)/gpu_monitor.py --log=$(shell pwd)/logs/ --name=$(node) --interval=60  > /dev/null 2>&1 &'"

# Removes a minion (monitoring GPU usage) on a given node
#
# parameters:
# - required: node
remove-minion:
	ssh $(node) "docker rm -f gpu_minion"

# Starts all minions
#
start-all-minions:
	make start-minion node=fbgpu1 gpus=0,1,2,3,4,5,6,7
	make start-minion node=gpu18 gpus=0,1
	make start-minion node=gpu17 gpus=0,1
	make start-minion node=gpu16 gpus=0,1
	make start-minion node=gpu15 gpus=0,1
	make start-minion node=gpu14 gpus=0,1
	make start-minion node=gpu9 gpus=0,1,2,3
	make start-minion node=gpu8 gpus=0,1,2,3
	make start-minion node=gpu7 gpus=0,1
	make start-minion node=gpu6 gpus=0,1
	make start-minion node=gpu5 gpus=0,1
	make start-minion node=gpu4 gpus=0,1
	make start-minion node=sys1 gpus=0,1,2,3
	make start-minion node=sys2 gpus=0,1,2,3
	make start-minion node=sys3 gpus=0,1,2,3

# Remove all minions
#
remove-all-minions:
	-make remove-minion node=fbgpu1 &
	-make remove-minion node=gpu18 &
	-make remove-minion node=gpu17 &
	-make remove-minion node=gpu16 &
	-make remove-minion node=gpu15 &
	-make remove-minion node=gpu14 &
	-make remove-minion node=gpu9 &
	-make remove-minion node=gpu8 &
	-make remove-minion node=gpu7 &
	-make remove-minion node=gpu6 &
	-make remove-minion node=gpu5 &
	-make remove-minion node=gpu4 &
	-make remove-minion node=sys1 &
	-make remove-minion node=sys2 &
	-make remove-minion node=sys3 &

# Start individual minions
start-minion-fb1:
	make start-minion node=fbgpu1 gpus=0,1,2,3,4,5,6,7

start-minion-18:
	make start-minion node=gpu18 gpus=0,1

start-minion-17:
	make start-minion node=gpu17 gpus=0,1

start-minion-16:
	make start-minion node=gpu16 gpus=0,1

start-minion-15:
	make start-minion node=gpu15 gpus=0,1

start-minion-14:
	make start-minion node=gpu14 gpus=0,1

start-minion-9:
	make start-minion node=gpu9 gpus=0,1,2,3

start-minion-8:
	make start-minion node=gpu8 gpus=0,1,2,3

start-minion-7:
	make start-minion node=gpu7 gpus=0,1

start-minion-6:
	make start-minion node=gpu6 gpus=0,1

start-minion-5:
	make start-minion node=gpu5 gpus=0,1

start-minion-4:
	make start-minion node=gpu4 gpus=0,1

start-minion-sys1:
	make start-minion node=sys1 gpus=0,1,2,3

start-minion-sys2:
	make start-minion node=sys2 gpus=0,1,2,3

start-minion-sys3:
	make start-minion node=sys3 gpus=0,1,2,3

remove-minion-fb1:
	make remove-minion node=fbgpu1

remove-minion-18:
	make remove-minion node=gpu18

remove-minion-17:
	make remove-minion node=gpu17

remove-minion-16:
	make remove-minion node=gpu16

remove-minion-15:
	make remove-minion node=gpu15

remove-minion-14:
	make remove-minion node=gpu14

remove-minion-9:
	make remove-minion node=gpu9

remove-minion-8:
	make remove-minion node=gpu8

remove-minion-7:
	make remove-minion node=gpu7

remove-minion-6:
	make remove-minion node=gpu6

remove-minion-5:
	make remove-minion node=gpu5

remove-minion-4:
	make remove-minion node=gpu4

remove-minion-sys1:
	make remove-minion node=sys1

remove-minion-sys2:
	make remove-minion node=sys2

remove-minion-sys3:
	make remove-minion node=sys3
