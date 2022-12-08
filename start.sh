#!/usr/bin/env bash
DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR"

while getopts "p:f:l" OPTION 2> /dev/null; do
	case ${OPTION} in
		p)
			PHP_BINARY="$OPTARG"
			;;
		f)
			POCKETMINE_FILE="$OPTARG"
			;;
		l)
			DO_LOOP="yes"
			;;
		\?)
			break
			;;
	esac
done

if [ "$PHP_BINARY" == "" ]; then
	if [ -f ./bin/php7/bin/php ]; then
		export PHPRC=""
		PHP_BINARY="./bin/php7/bin/php"
	elif [[ ! -z $(type php 2> /dev/null) ]]; then
		PHP_BINARY=$(type -p php)
	else
		echo "Couldn't find a PHP binary in system PATH or $PWD/bin/php7/bin"
		echo "Please refer to the installation instructions at https://doc.pmmp.io/en/rtfd/installation.html"
		exit 1
	fi
fi

if [ "$NGROK_BINARY" == "" ]; then
	if [ -f ./bin/ngrok3/bin/ngrok ]; then
		export NGROK_BINARY="./bin/ngrok3/bin/ngrok"
	elif [[ ! -z $(type ngrok 2> /dev/null) ]]; then
		NGROK_BINARY=$(type -p ngrok)
	else
		echo "Couldn't find a ngrok binary in the system PATH or $PWD/bin/ngrok3/bin"
		echo "Please refer to the installation instructions at https://ngrok.com/download"
		exit 1
	fi
fi


if [ "$POCKETMINE_FILE" == "" ]; then
	if [ -f ./PocketMine-MP.phar ]; then
		POCKETMINE_FILE="./PocketMine-MP.phar"
	else
		echo "PocketMine-MP.phar not found"
		echo "Downloads can be found at https://github.com/pmmp/PocketMine-MP/releases"
		exit 1
	fi
fi

exec "$NGROK_BINARY" config add-authtoken "$NGROK_AUTH_TOKEN"
exec "$NGROK_BINARY" tcp 19132 &

LOOPS=0

set +e

if [ "$DO_LOOP" == "yes" ]; then
	while true; do
		if [ ${LOOPS} -gt 0 ]; then
			echo "Restarted $LOOPS times"
		fi
		"$PHP_BINARY" "$POCKETMINE_FILE" $@
		echo "To escape the loop, press CTRL+C now. Otherwise, wait 5 seconds for the server to restart."
		echo ""
		sleep 5
		((LOOPS++))
	done
else
	exec "$PHP_BINARY" "$POCKETMINE_FILE" $@
fi
