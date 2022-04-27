##################################################
## "wine" stage
##################################################

FROM docker.io/hectorm/xubuntu:latest AS main

# Environment
ENV WINEARCH=win64
ENV WINEDEBUG=warn+all

# Add Wine repository
RUN curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xD43F640145369C51D786DDEA76F1A20FF987672F' | gpg --dearmor -o /etc/apt/trusted.gpg.d/wine.gpg \
	&& printf '%s\n' "deb [signed-by=/etc/apt/trusted.gpg.d/wine.gpg] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > "/etc/apt/sources.list.d/wine.list"

# Add Lutris repository
RUN curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x82D96E430A1F1C0F0502747E37B90EDD4E3EFAE4' | gpg --dearmor -o /etc/apt/trusted.gpg.d/lutris.gpg \
	&& printf '%s\n' "deb [signed-by=/etc/apt/trusted.gpg.d/lutris.gpg] http://ppa.launchpad.net/lutris-team/lutris/ubuntu/ $(lsb_release -cs) main" > "/etc/apt/sources.list.d/lutris.list"

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
