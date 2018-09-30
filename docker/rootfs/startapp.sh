#!/bin/bash -ex

export HOME=/config

#install/update server on startup
/opt/service/steamcmd/steamcmd \
		+@sSteamCmdForcePlatformType windows \
		+login $STEAMNAME $STEAMPASSWORD \
		+force_install_dir /opt/dayzserver \
		+app_update 223350 validate \
		+quit

if [ -d /opt/dayzserver/mpmissions ]
then
	mv /opt/dayzserver/mpmissions /opt/dayzserver/mpmissions.template
	rm /opt/dayzserver/mpmissions
	ln -s ${HOME}/mpmissions /opt/dayzserver/mpmissions
fi

if [ ! -d "${HOME}/mpmissions" ]
then
	cp -vr /opt/dayzserver/mpmissions.template "${HOME}/mpmissions"
fi

WINE_DEBUG=-all WINEDLLOVERRIDES="mscoree=,mshtml=" wineboot -eu

# parse DAYZSERVER_CLI_* variables into -name=value arguments
SERVER_ARGS=()
while IFS='=' read -r name value
do
	name="${name/DAYZSERVER_CLI_/}"
	name="$(tr '[[:upper:]]' '[[:lower:]]' <<< "${name}" | sed -r 's/(_)(([^_])([^_]*))?/\U\3\L\4/g')"
	case "${value}" in
		true|yes|1)
			SERVER_ARGS+=("-$name")
			;;
		*)
			SERVER_ARGS+=("-$name=$value")
			;;
	esac
done < <(env | grep 'DAYZSERVER_CLI_')

echo "Arguments:" "${SERVER_ARGS[@]}"

exec wine /opt/dayzserver/DayZServer_x64.exe "${SERVER_ARGS[@]}" "$@"
