##################################################
## "wine" stage
##################################################

FROM docker.io/hectormolinero/xubuntu:latest AS wine

# Environment
ENV WINEARCH=win64
ENV WINEDEBUG=warn+all
ENV UNPRIVILEGED_USER_NAME=wine

# Add Wine repository
RUN curl -fsSL 'https://dl.winehq.org/wine-builds/winehq.key' | apt-key add - \
	&& printf '%s\n' 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' > /etc/apt/sources.list.d/wine.list

# Add Wine OBS repository (see: https://forum.winehq.org/viewtopic.php?f=8&t=32192)
RUN curl -fsSL 'https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key' | apt-key add - \
	&& printf '%s\n' 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./' > /etc/apt/sources.list.d/wine-obs.list

# Install system packages
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		cabextract \
		dosbox \
		exe-thumbnailer \
		make \
		wimtools \
		winbind \
		winehq-devel \
	&& rm -rf /var/lib/apt/lists/*

# Install Winetricks
ARG WINETRICKS_TREEISH=master
ARG WINETRICKS_REMOTE=https://github.com/Winetricks/winetricks.git
RUN mkdir /tmp/winetricks/ && cd /tmp/winetricks/ \
	&& git clone "${WINETRICKS_REMOTE:?}" ./ \
	&& git checkout "${WINETRICKS_TREEISH:?}" \
	&& git submodule update --init --recursive \
	&& make install \
	&& rm -rf /tmp/winetricks/

# Install Microsoft Windows 10 fonts
ARG WIN10_ISO_URL=https://software-download.microsoft.com/download/pr/18363.418.191007-0143.19h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso
ARG WIN10_ISO_CHECKSUM=9ef81b6a101afd57b2dbfa44d5c8f7bc94ff45b51b82c5a1f9267ce2e63e9f53
RUN mkdir /tmp/win10/ && cd /tmp/win10/ \
	&& curl -Lo ./win10.iso "${WIN10_ISO_URL:?}" \
	&& echo "${WIN10_ISO_CHECKSUM:?}  ./win10.iso" | sha256sum -c \
	&& 7z e ./win10.iso sources/install.wim \
	&& wimextract install.wim 1 /Windows/Fonts/* --dest-dir /usr/share/fonts/win10/ \
	&& fc-cache -fv \
	&& rm -rf /tmp/win10/
