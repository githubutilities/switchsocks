#! /bin/sh
function set_proxy () {
	local PROTOCOL=$1
	local PROXY_SERVER_IP=$2
	local PROXY_SERVER_PORT=$3
	local SWITCHER_DIR=$4

	local PROXY_SERVER_ADDRESS=$PROTOCOL'://'$PROXY_SERVER_IP':'$PROXY_SERVER_PORT
	
	# config ssh proxy for git
	export GIT_SSH=$(init_proxy_wrapper_for_ssh $PROXY_SERVER_IP $PROXY_SERVER_PORT $SWITCHER_DIR)

	# config http and https proxy for git
	git config --global http.proxy $PROXY_SERVER_ADDRESS
	git config --global https.proxy $PROXY_SERVER_ADDRESS

	# config git proxy for git
	git config --global core.gitproxy $(init_proxy_wrapper_for_git $PROXY_SERVER_IP $PROXY_SERVER_PORT $SWITCHER_DIR)
}

function unset_proxy() {
	local SWITCHER_DIR=$1

	# unsetting ssh proxy for git
	unset GIT_SSH

	# unsetting http and https proxy for git
	git config --global --unset http.proxy
	git config --global --unset https.proxy

	# unsetting git proxy for git
	git config --global --unset core.gitproxy

	# remove the genereted wrapper script in switcher directory
	rm -r $SWITCHER_DIR
}


function is_proxy_running() {
	lsof -i :$1 | grep LISTEN &> /dev/null
	if [ $? -eq 0 ] 
	then
		# proxy running
		return 1;

	else
		# proxy not running
		return 0;
	
	fi
}

function init_switcher_dir() {
	local SWITCHER_DIR=$1

	# create directory if not existed
	if [ ! -e $SWITCHER_DIR ]
		then
			mkdir $SWITCHER_DIR
	fi
}

function init_proxy_wrapper_for_ssh() {
	local PROXY_SERVER_IP=$1
	local PROXY_SERVER_PORT=$2
	local SWITCHER_DIR=$3
	local PROXY_SERVER_ADDRESS=$PROXY_SERVER_IP":"$PROXY_SERVER_PORT

	init_switcher_dir $SWITCHER_DIR

	# init proxy wrapper
	# file: proxywrapper4ssh
	##! /bin/sh
	#ssh -o ProxyCommand="nc -x 127.0.0.1:1080 %h %p" "$@"
	local GIT_PROXY_WRAPPER=$SWITCHER_DIR"/proxywrapper4ssh"
	local BASH_SCRIPT_HEADER='#! /bin/sh'
	if [ ! -e $GIT_PROXY_WRAPPER ]
	then
		local GIT_PROXY_STR='ssh -o ProxyCommand="nc -x '$PROXY_SERVER_ADDRESS' %h %p" "$@"'
		echo $BASH_SCRIPT_HEADER > $GIT_PROXY_WRAPPER
		echo $GIT_PROXY_STR >> $GIT_PROXY_WRAPPER
		chmod +x $GIT_PROXY_WRAPPER
	fi
	echo $GIT_PROXY_WRAPPER
}

function init_proxy_wrapper_for_git() {
	local PROXY_SERVER_IP=$1
	local PROXY_SERVER_PORT=$2
	local SWITCHER_DIR=$3
	local PROXY_SERVER_ADDRESS=$PROXY_SERVER_IP":"$PROXY_SERVER_PORT

	init_switcher_dir $SWITCHER_DIR

	# init proxy wrapper
	# file: proxywrapper4git
	##! /bin/sh
	#nc -X5 -x 127.0.0.1:1080 $*
	local GIT_PROXY_WRAPPER=$SWITCHER_DIR"/proxywrapper4git"
	local BASH_SCRIPT_HEADER='#! /bin/sh'
	if [ ! -e $GIT_PROXY_WRAPPER ]
	then
		local GIT_PROXY_STR='nc -X5 -x '$PROXY_SERVER_ADDRESS' $*'
		echo $BASH_SCRIPT_HEADER > $GIT_PROXY_WRAPPER
		echo $GIT_PROXY_STR >> $GIT_PROXY_WRAPPER
		chmod +x $GIT_PROXY_WRAPPER
	fi
	echo $GIT_PROXY_WRAPPER
}

function main() {

	# your proxy protocol
	local PROTOCOL='socks5'

	# your proxy ip
	local PROXY_SERVER_IP="127.0.0.1"

	# your proxy port
	local PROXY_SERVER_PORT="1080"

	#`/tmp` will be cleaned every reboot
	local SWITCHER_DIR='/tmp/proxyswitcher'


	if is_proxy_running $PROXY_SERVER_PORT
	then
		echo "no proxy running"
		echo "start cleaning up..."
		unset_proxy $SWITCHER_DIR
	else
		echo "proxy running on port" $PROXY_SERVER_PORT
		echo "start setting up..."
		set_proxy $PROTOCOL $PROXY_SERVER_IP $PROXY_SERVER_PORT $SWITCHER_DIR
	fi
}

main
