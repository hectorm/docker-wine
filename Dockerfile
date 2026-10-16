# syntax=docker.io/docker/dockerfile:1

##################################################
## "main" stage
##################################################

FROM docker.io/hectorm/xubuntu:v136 AS main

# Environment
ENV WINEDEBUG=fixme-all

# Add Wine repository
COPY --chown=root:root --chmod=a+rX,u+w,go-w ./config/apt/keyrings/ /etc/apt/keyrings/
RUN <<-EOF
	printf '%s\n' > /etc/apt/sources.list.d/winehq.sources \
		'Types: deb' \
		'URIs: https://dl.winehq.org/wine-builds/ubuntu/' \
		"Suites: $(lsb_release -cs)" \
		'Components: main' \
		'Signed-By: /etc/apt/keyrings/winehq.asc'
EOF

# Install packages
RUN <<-EOF
	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get install -y --no-install-recommends -o APT::Immediate-Configure=0 \
		7zip \
		7zip-rar \
		aria2 \
		cabextract \
		dos2unix \
		dosbox \
		exe-thumbnailer \
		gdb \
		gstreamer1.0-plugins-bad \
		gstreamer1.0-plugins-ugly \
		innoextract \
		libodbc2 \
		msitools \
		rar \
		unrar \
		unshield \
		wimtools \
		winbind \
		winehq-devel \
		xchm \
		zenity
	rm -rf /var/lib/apt/lists/*
EOF

# Install Winetricks
RUN <<-EOF
	WINETRICKS_URL='https://github.com/Winetricks/winetricks/archive/refs/heads/master.tar.gz'
	WINETRICKS_DIR=$(mktemp -d)
	curl --proto '=https' --tlsv1.3 -sSfL "${WINETRICKS_URL:?}" | tar -xzC "${WINETRICKS_DIR:?}" --strip-components=1
	cd "${WINETRICKS_DIR:?}"/src/
	install -Dm 755 ./winetricks /usr/local/bin/winetricks
	install -Dm 644 ./winetricks.1 /usr/local/share/man/man1/winetricks.1
	install -Dm 644 ./winetricks.desktop /usr/local/share/applications/winetricks.desktop
	install -Dm 644 ./io.github.winetricks.Winetricks.metainfo.xml /usr/local/share/metainfo/io.github.winetricks.Winetricks.metainfo.xml
	install -Dm 644 ./winetricks.svg /usr/local/share/icons/hicolor/scalable/apps/winetricks.svg
	install -Dm 644 ./winetricks.bash-completion /usr/local/share/bash-completion/completions/winetricks
	cd / && rm -rf "${WINETRICKS_DIR:?}"
EOF

# Install Mono and Gecko
RUN <<-EOF
	WINE_VERSION=$(wine --version)
	ADDONS_C_URL="https://gitlab.winehq.org/wine/wine/-/raw/${WINE_VERSION:?}/dlls/appwiz.cpl/addons.c"
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
