FROM debian:stretch-slim

LABEL Maintainer="akahana<akahana@akahana.jp>"
LABEL Desciption="tex build environment with Adobe Source Han Fonts"

ARG TL_VERSION="2019"
ARG REPOSITORY="ftp://tug.org/historic/systems/texlive/${TL_VERSION}"
ENV PATH="/usr/local/texlive/${TL_VERSION}/bin/x86_64-linux:$PATH"


RUN set -x \
	&& apt-get update -qq \
	&& apt-get install --no-install-recommends -y -qq \
		wget perl libwww-perl fontconfig unzip ghostscript \
	&& mkdir /tmp/install-tl-unx \
	&& wget -qO - ${REPOSITORY}/install-tl-unx.tar.gz | tar -xz -C /tmp/install-tl-unx --strip-components 1 \ 
	&& cd /tmp/install-tl-unx \
	&& printf "%s\n" "selected_scheme scheme-full" "option_doc 0" "option_src 0" > texlive.profile \
	&& ./install-tl -profile texlive.profile \
	&& tlmgr update --self --all \
	&& cp $(kpsewhich -var-value TEXMFSYSVAR)/fonts/conf/texlive-fontconfig.conf \
		 /etc/fonts/conf.d/09-texlive.conf \
# フォントの整備
	&& cd /tmp \
	&& wget -q https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_M-H.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_EL-R.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_EL-M.zip \
	&& wget -q https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_SB-H.zip \
# unzipでglobを指定するときはエスケープが必要
	&& unzip -j SourceHanSans\*.zip *.ttc -d /tmp/SourceHanSans \
	&& unzip -j SourceHanSerif\*.zip *.ttc -d /tmp/SourceHanSerif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans \
	&& mv /tmp/SourceHanSans/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans/ \
	&& mv /tmp/SourceHanSerif/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif/ \
	&& fc-cache -fsv \
	&& mktexlsr \
	&& luaotfload-tool -fv \
# クリーニング
	&& cd / \
	&& apt-get purge -qq -y wget unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \

WORKDIR /root

COPY .latexmkrc /root/.latexmkrc

CMD [ "/bin/bash" ]
