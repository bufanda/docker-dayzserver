FROM jlesage/baseimage-gui:debian-9

ARG steamname=anonymous
ARG steampassword=0000

# wine
ADD https://dl.winehq.org/wine-builds/Release.key /wine-builds.key
RUN \
	export DEBIAN_FRONTEND=noninteractive \
	&& apt-get -y update \
	&& apt-get -y install gnupg2 apt-transport-https \
	&& apt-key add /wine-builds.key \
	&& rm /wine-builds.key

RUN \
	export DEBIAN_FRONTEND=noninteractive \
	&& dpkg --add-architecture i386 \
	&& echo "deb https://dl.winehq.org/wine-builds/debian/ stretch main" >> /etc/apt/sources.list.d/wine.list \
	&& apt-get -y update \
	&& add-pkg winehq-stable procps

WORKDIR   /opt/service/steamcmd

RUN (wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz) && \
	  (tar -xzf steamcmd_linux.tar.gz) && (rm steamcmd_linux.tar.gz)

RUN export DEBIAN_FRONTEND=noninteractive \
		apt-get install lib32gcc1

RUN \
		/opt/service/steamcmd/steamcmd \
		+login $steamname $steampassword \
		+force_install_dir /opt/dayzserver \
		+app_update 223350 validate \
		+quit


COPY . /opt/dayzserver/

# RUN useradd -k /var/empty -G tty -m -N -r dayzserver

COPY docker/rootfs/ /
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/local/bin/gosu
RUN chmod -v a+x /usr/local/bin/* /*.sh
RUN mv -v /opt/dayzserver/mpmissions /opt/dayzserver/mpmissions.template && ln -s /config/mpmissions /opt/dayzserver/mpmissions
ENV APP_NAME="DayZ Server"
WORKDIR /config
