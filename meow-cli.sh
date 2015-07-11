NAME=meow-cli
VERSION=1.0.0

main() {
  local help=\
"Usage: $NAME [options] <command> [<arguments>...]
Options:
  -v, --version   print version"
}

# script=$(readlink -f "$0")
dir=$(dirname "$script")

success() {
	meow "$1" "Ok" '\e[1;32m'
}

info() {
	meow "$1" "Info" '\e[1;34m'
}

warning() {
	meow "$1" "Warn" '\e[1;33m'
}

error() {
	meow "$1" "Error" '\e[1;31m'
}

debug() {
	return 1
}

meow() {
	local message="$1"

	if [[ -n "$2" ]]; then
		local token="$2"
		local color="$3"
		local nc='\e[0m'
		local tab=$'\t'
		meow -e "[${color}${token}${nc}]${tab} $message${nc}"
	else
		meow "$message"
	fi
}

start() {
	info "starting..."	

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
				success "${!service} started"
			else
				error "${!service} not started"
				#debug "${result}"
			fi
		else
			success "${!name} reloaded"
		fi
	done

	info "started"
}

stop() {
	info "stopping..."	

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
				error "${!service} not stopped"
				meow "${result}"
			else
				success "${!service} stopped"
			fi
		else
			success "${!name} reloaded"
		fi
	done

	info "stopped"	
}

if [ "$(id -u)" != "0" ]; then
	error "This is a Linux thingy... Don't try to crack sudo!"
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
			meow "Usage: rewned {start|stop|restart}"
		;;
	esac
fi

read -n 1 -p "Press any key..."
echo ""
exit 1
