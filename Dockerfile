FROM debian:latest

MAINTAINER akahana_1<aakahana@gmail.com>
LABEL Desciption="tex build environment using (u)pLaTeX with Adobe Source Han Fonts"

ARG REPOSITORY="http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/"
ARG INSTALLER="install-tl-unx.tar.gz"
ARG TL_VERSION="2017"

COPY texlive.profile .

RUN set -x \
	&& apt update \
	&& apt dist-upgrade -y \
	&& apt install --no-install-recommends -y \
		wget perl fontconfig libwww-perl unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget ${REPOSITORY}${INSTALLER} \
	&& tar xvf ${INSTALLER} \
	&& ./install-tl-*/install-tl -profile texlive.profile -repository ${REPOSITORY} \
ENV PATH /usr/local/texlive/${TL_VERSION}/bin/x86-64_linux:$PATH
RUN set -x \
	&& tlmgr init-usertree \
	&& tlmgr update --self --all \
	&& cp $(kpsewhich -var-value TEXMFSYSVAR)/fonts/conf/texlive-fontconfig.conf /etc/fonts/conf.d/09-texlive.conf \
# フォントの整備
	&& cd /tmp \
	&& wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_M-H.zip \
	&& wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTC/SourceHanSansOTC_EL-R.zip \
	&& wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_EL-M.zip \
	&& wget https://github.com/adobe-fonts/source-han-serif/raw/release/OTC/SourceHanSerifOTC_SB-H.zip \
# unzipでglobを指定するときはエスケープが必要
	&& unzip SourceHan\*.zip \
# RUNはsh -cで走るのでbash拡張が使えない
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif \
	&& mkdir -p $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans \
	&& mv SourceHanSansOTC*/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehansans/ \
	&& mv SourceHanSerifOTC*/*.ttc $(kpsewhich -var-value TEXMFLOCAL)/fonts/opentype/adobe/sourcehanserif/ \
	&& fc-cache -fsv \
# Takayuki YATO氏によるライブラリのインストール
# PXchfon
	&& tlmgr install pxchfon \
# クリーニング
	&& cd / \
	&& rm -rf /tmp/* \
	&& rm -rf install-tl*

WORKDIR /root

COPY .latexmkrc /root/.latexmkrc

CMD [ "/bin/bash" ]
