FROM debian:stretch-slim

LABEL Maintainer="akahana<akahana@akahana.jp>"
LABEL Desciption="tex build environment with Adobe Source Han Fonts"

ARG TL_VERSION="2019"
ARG REPOSITORY="ftp://tug.org/historic/systems/texlive/${TL_VERSION}/"
ENV PATH="/usr/local/texlive/${TL_VERSION}/bin/x86_64-linux:$PATH"


RUN set -x \
    && apt-get update -qq \
	&& apt-get install --no-install-recommends -y -qq \
		wget perl libwww-perl unzip ghostscript \
	&& mkdir /tmp/install-tl-unx \
	&& wget -qO - ${REPOSITORY}/install-tl-unx.tar.gz | tar -xz -C /tmp/install-tl-unx --strip-components 1 \ 
	&& cd /tmp/install-tl-unx \
	&& printf "%s\n" "selected_scheme scheme-basic" "option_doc 0" "option_src 0" > texlive.profile \
	&& ./install-tl -profile texlive.profile \
	&& tlmgr update --self --all \
	&& tlmgr install collection-fontsrecommended collection-langjapanese \
	collection-latexextra collection-latexrecommended collection-luatex latexmk \
# Adding Source Hans Fonts
	&& wget -q https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_M-H.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_EL-R.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_EL-M.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_SB-H.zip \
	&& unzip -j SourceHanSans\*.zip *.ttc -d /tmp/SourceHanSans \
	&& unzip -j SourceHanSerif\*.zip *.ttc -d /tmp/SourceHanSerif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans \
	&& mv /tmp/SourceHanSans/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans/ \
	&& mv /tmp/SourceHanSerif/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif/ \
	&& mktexlsr \
	&& luaotfload-tool -fv \
# cleanup
	&& apt-get purge -qq -y wget unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

WORKDIR /root

COPY .latexmkrc /root/latexmkrc

CMD [ "/bin/bash" ]
