##################################################
## "main" stage
##################################################

FROM docker.io/hectorm/xubuntu:v119 AS main

# Environment
ENV WINEARCH=win64
ENV WINEDEBUG=warn+all

# Add Wine repository
RUN <<-EOF
	curl --proto '=https' --tlsv1.3 -sSf 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xD43F640145369C51D786DDEA76F1A20FF987672F' | gpg --dearmor -o /etc/apt/trusted.gpg.d/wine.gpg
	printf '%s\n' "deb [signed-by=/etc/apt/trusted.gpg.d/wine.gpg] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/wine.list
EOF

# Install packages
RUN <<-EOF
	export DEBIAN_FRONTEND=noninteractive
	dpkg --add-architecture i386
	apt-get update
	apt-get install -y --no-install-recommends -o APT::Immediate-Configure=0 \
		cabextract \
		dos2unix \
		dosbox \
		exe-thumbnailer \
		libvkd3d-utils1 \
		libvkd3d1 \
		p7zip-full \
		p7zip-rar \
		vkd3d-compiler \
		vkd3d-demos \
		wimtools \
		winbind \
		winehq-devel \
		winetricks \
		xchm \
		zenity
	rm -rf /var/lib/apt/lists/*
EOF
