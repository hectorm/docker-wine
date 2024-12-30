##################################################
## "main" stage
##################################################

FROM docker.io/hectorm/xubuntu:v122 AS main

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

# Install Mono and Gecko
RUN <<-EOF
	ADDONS_C_URL='https://gitlab.winehq.org/wine/wine/-/raw/master/dlls/appwiz.cpl/addons.c'
	ADDONS_C_CONTENT=$(curl --proto '=https' --tlsv1.3 -sSf "${ADDONS_C_URL:?}")
	MONO_DIR='/opt/wine-devel/share/wine/mono/'
	MONO_VERSION=$(printf '%s\n' "${ADDONS_C_CONTENT:?}" | awk -F '"' '/^#define MONO_VERSION "[0-9]+(\.[0-9]+)+"$/{print($2)}')
	MONO_X86_URL="https://dl.winehq.org/wine/wine-mono/${MONO_VERSION:?}/wine-mono-${MONO_VERSION:?}-x86.tar.xz"
	mkdir -p "${MONO_DIR:?}" && curl --proto '=https' --tlsv1.2 -sSfL "${MONO_X86_URL:?}" | tar -xJC "${MONO_DIR:?}"
	GECKO_DIR='/opt/wine-devel/share/wine/gecko/'
	GECKO_VERSION=$(printf '%s\n' "${ADDONS_C_CONTENT:?}" | awk -F '"' '/^#define GECKO_VERSION "[0-9]+(\.[0-9]+)+"$/{print($2)}')
	GECKO_x86_URL="https://dl.winehq.org/wine/wine-gecko/${GECKO_VERSION:?}/wine-gecko-${GECKO_VERSION:?}-x86.tar.xz"
	GECKO_X86_64_URL="https://dl.winehq.org/wine/wine-gecko/${GECKO_VERSION:?}/wine-gecko-${GECKO_VERSION:?}-x86_64.tar.xz"
	mkdir -p "${GECKO_DIR:?}" && curl --proto '=https' --tlsv1.2 -sSfL "${GECKO_x86_URL:?}" | tar -xJC "${GECKO_DIR:?}"
	mkdir -p "${GECKO_DIR:?}" && curl --proto '=https' --tlsv1.2 -sSfL "${GECKO_X86_64_URL:?}" | tar -xJC "${GECKO_DIR:?}"
EOF
