NAME=meow-cli
VERSION=1.0.0

function main {
  local help=\
"Usage: $NAME [options] <command> [<arguments>...]
Options:
  -v, --version   print version"
}

# script=$(readlink -f "$0")
dir=$(dirname "$script")

msg_success() {
	msg "$1" "Ok" '\e[1;32m'
}

msg_info() {
	msg "$1" "Info" '\e[1;34m'
}

msg_warning() {
	msg "$1" "Warn" '\e[1;33m'
}

msg_error() {
	msg "$1" "Error" '\e[1;31m'
}

msg_debug() {
	return 1
}

msg() {
	local message="$1"

	if [[ -n "$2" ]]; then
		local token="$2"
		local color="$3"
		local nc='\e[0m'
		local tab=$'\t'
		echo -e "[${color}${token}${nc}]${tab} $message${nc}"
	else
		echo "$message"
	fi
}

start() {
	msg_info "starting..."	

	for service in ${!services[*]}
	do
		val=${services[$service]}

		name="$val[name]"
		start="$val[start]"
		service="$val[service]"

		result=$( ${!start} 2> /dev/null  )

		if [[ -n "${!service}" ]]; then
			# Check if service started
			started=$(ps ax | grep -v grep | grep "${!service}")

			if [ -n "${started}" ]; then
				msg_success "${!service} started"
			else
				msg_error "${!service} not started"
				#msg_debug "${result}"
			fi
		else
			msg_success "${!name} reloaded"
		fi
	done

	msg_info "started"
}

stop() {
	msg_info "stopping..."	

	for service in ${!services[*]}
	do
		val=${services[$service]}

		name="$val[name]"
		stop="$val[stop]"
		service="$val[service]"

		result=$( ${!stop} 2> /dev/null  )
		sleep 0.2

		if [[ -n "${!service}" ]]; then
			# Check if service started
			started=$(ps ax | grep -v grep | grep "${!service}")

			if [ -n "${started}" ]; then
				msg_error "${!service} not stopped"
				echo "${result}"
			else
				msg_success "${!service} stopped"
			fi
		else
			msg_success "${!name} reloaded"
		fi
	done

	msg_info "stopped"	
}

if [ "$(id -u)" != "0" ]; then
	msg_error "This is a Linux thingy... Don't try to crack sudo!"
else
	. $dir/services

	case $1 in
		start)
			start
		;;
		stop)
			stop
		;;
		restart)
			stop
			start
		;;
		*)
			msg "Usage: rewned {start|stop|restart}"
		;;
	esac
fi

read -n 1 -p "Press any key..."
echo ""
exit 1
