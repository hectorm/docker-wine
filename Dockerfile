##################################################
## "wine" stage
##################################################

FROM docker.io/hectormolinero/xubuntu:latest AS wine

# Environment
ENV WINEARCH=win64
ENV WINEDEBUG=warn+all
ENV UNPRIVILEGED_USER_NAME=wine

# Add Wine repository
RUN printf '%s\n' "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/wine.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D43F640145369C51D786DDEA76F1A20FF987672F

# Add Lutris repository
RUN printf '%s\n' "deb http://ppa.launchpad.net/lutris-team/lutris/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/lutris.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82D96E430A1F1C0F0502747E37B90EDD4E3EFAE4

# Install system packages
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& apt-get install -y --no-install-recommends \
		cabextract \
		dosbox \
		exe-thumbnailer \
		libvkd3d1 \
		lutris \
		make \
		wimtools \
		winbind \
		winehq-stable \
	&& rm -rf /var/lib/apt/lists/*

# Install Microsoft Windows 10 fonts
ARG WIN10_ISO_URL=https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso
ARG WIN10_ISO_CHECKSUM=f1a4f2176259167cd2c8bf83f3f5a4039753b6cc28c35ac624da95a36e9620fc
RUN mkdir /tmp/win10/ && cd /tmp/win10/ \
	&& curl -Lo ./win10.iso "${WIN10_ISO_URL:?}" \
	&& printf '%s' "${WIN10_ISO_CHECKSUM:?}  ./win10.iso" | sha256sum -c \
	&& 7z e ./win10.iso sources/install.wim \
	&& wimextract install.wim 1 /Windows/Fonts/* --dest-dir /usr/share/fonts/win10/ \
	&& fc-cache -fv \
	&& rm -rf /tmp/win10/
