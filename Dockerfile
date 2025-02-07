# Usamos a imagem Debian 12.5
FROM debian:12.5

LABEL org.opencontainers.image.authors="github@diouxx.be"

# Não fazer perguntas durante a instalação
ENV DEBIAN_FRONTEND noninteractive

# Instalação de pacotes essenciais
RUN apt update \
    && apt install --yes ca-certificates apt-transport-https lsb-release wget curl git \
    openssh-server nano tzdata \
    && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
    && apt update \
    && apt install --yes --no-install-recommends \
    apache2 \
    php8.1 \
    php8.1-mysql \
    php8.1-ldap \
    php8.1-xmlrpc \
    php8.1-imap \
    php8.1-curl \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-xml \
    php-cas \
    php8.1-intl \
    php8.1-zip \
    php8.1-bz2 \
    php8.1-redis \
    cron \
    jq \
    libldap-2.5-0 \
    libldap-common \
    libsasl2-2 \
    libsasl2-modules \
    libsasl2-modules-db \
    && rm -rf /var/lib/apt/lists/*

# Configurar TimeZone corretamente
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo "America/Sao_Paulo" > /etc/timezone

# Configurar TimeZone no PHP (CLI e Apache)
RUN echo "date.timezone = America/Sao_Paulo" > /etc/php/8.1/apache2/php.ini \
    && echo "date.timezone = America/Sao_Paulo" > /etc/php/8.1/cli/php.ini

# Configurar segurança para sessões (cookies httponly)
RUN echo "session.cookie_httponly = On" >> /etc/php/8.1/apache2/php.ini \
    && echo "session.cookie_httponly = On" >> /etc/php/8.1/cli/php.ini

# Copiar e executar script de inicialização do GLPI
COPY glpi-start.sh /opt/
RUN chmod +x /opt/glpi-start.sh
ENTRYPOINT ["/opt/glpi-start.sh"]

# Exposição das portas
EXPOSE 80 443
