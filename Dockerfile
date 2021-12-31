##################################################
## "wine" stage
##################################################

FROM docker.io/hectormolinero/xubuntu:latest AS wine

# Environment
ENV WINEARCH=win64
ENV WINEDEBUG=warn+all

# Add Wine repository
RUN printf '%s\n' "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/wine.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D43F640145369C51D786DDEA76F1A20FF987672F

# Add Lutris repository
RUN printf '%s\n' "deb http://ppa.launchpad.net/lutris-team/lutris/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/lutris.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 82D96E430A1F1C0F0502747E37B90EDD4E3EFAE4

# Install system packages
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		cabextract \
		dos2unix \
		dosbox \
		exe-thumbnailer \
		libvkd3d-utils1 \
		libvkd3d1 \
		lutris \
		p7zip-full \
		p7zip-rar \
		vkd3d-compiler \
		vkd3d-demos \
		wimtools \
		winbind \
		winehq-stable \
		xchm \
	&& rm -rf /var/lib/apt/lists/*
