# Demyx
# https://demyx.sh

if [[ "$DEMYX_APP_SSL" = true ]]; then
    DEMYX_YML_NGINX_PHP_LABEL_HTTP='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(`${DEMYX_APP_DOMAIN}`) || Host(`www.${DEMYX_APP_DOMAIN}`)"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http"

      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80"

      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=https"
        
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(`${DEMYX_APP_DOMAIN}`) || Host(`www.${DEMYX_APP_DOMAIN}`)"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx"
    
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80"'
    DEMYX_YML_NGINX_PHP_LABEL_AUTH_PROTO=https
else
    DEMYX_YML_NGINX_PHP_LABEL_HTTP='- "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.rule=Host(`${DEMYX_APP_DOMAIN}`) || Host(`www.${DEMYX_APP_DOMAIN}`)"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.entrypoints=http"

      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-http.service=${DEMYX_APP_COMPOSE_PROJECT}-http-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-http-port.loadbalancer.server.port=80"

      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.middlewares=${DEMYX_APP_COMPOSE_PROJECT}-redirect"
      - "traefik.http.middlewares.${DEMYX_APP_COMPOSE_PROJECT}-redirect.redirectscheme.scheme=http"

      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.rule=Host(`${DEMYX_APP_DOMAIN}`) || Host(`www.${DEMYX_APP_DOMAIN}`)"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.entrypoints=https"
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.tls.certresolver=demyx"
                
      - "traefik.http.routers.${DEMYX_APP_COMPOSE_PROJECT}-https.service=${DEMYX_APP_COMPOSE_PROJECT}-https-port"
      - "traefik.http.services.${DEMYX_APP_COMPOSE_PROJECT}-https-port.loadbalancer.server.port=80"'
    DEMYX_YML_NGINX_PHP_LABEL_AUTH_PROTO=http
fi

if [[ "$DEMYX_APP_AUTH" = true || -n "$DEMYX_RUN_AUTH" ]]; then
    DEMYX_YML_NGINX_PHP_LABEL_AUTH="- \"traefik.http.routers.\${DEMYX_APP_COMPOSE_PROJECT}-${DEMYX_YML_NGINX_PHP_LABEL_AUTH_PROTO}.middlewares=\${DEMYX_APP_COMPOSE_PROJECT}-auth\"
      - \"traefik.http.middlewares.\${DEMYX_APP_COMPOSE_PROJECT}-auth.basicauth.users=\${DEMYX_APP_AUTH_HTPASSWD}\""
fi

echo "# AUTO GENERATED
version: \"$DEMYX_DOCKER_COMPOSE\"
services:
  nx_${DEMYX_APP_ID}:
    image: demyx/nginx
    cpus: \${DEMYX_APP_WP_CPU}
    mem_limit: \${DEMYX_APP_WP_MEM}
    restart: unless-stopped
    networks:
      - demyx
    depends_on:
      - db_${DEMYX_APP_ID}
    environment:
      - WORDPRESS=true
      - WORDPRESS_CONTAINER=\${DEMYX_APP_WP_CONTAINER}
      - NGINX_DOMAIN=\${DEMYX_APP_DOMAIN}
      - NGINX_CACHE=\${DEMYX_APP_CACHE}
      - NGINX_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
      - NGINX_RATE_LIMIT=\${DEMYX_APP_RATE_LIMIT}
      - NGINX_XMLRPC=\${DEMYX_APP_XMLRPC}
      - NGINX_BASIC_AUTH=\${DEMYX_APP_AUTH_WP}
      - NGINX_BASIC_AUTH_HTPASSWD=\${DEMYX_APP_AUTH_HTPASSWD}
      - TZ=$TZ
    volumes:
      - wp_${DEMYX_APP_ID}:/demyx
      - wp_${DEMYX_APP_ID}_log:/var/log/demyx
    labels:
      - \"traefik.enable=true\"
      $DEMYX_YML_NGINX_PHP_LABEL_HTTP
      ${DEMYX_YML_NGINX_PHP_LABEL_AUTH:-}
  wp_${DEMYX_APP_ID}:
    image: demyx/wordpress
    cpus: \${DEMYX_APP_WP_CPU}
    mem_limit: \${DEMYX_APP_WP_MEM}
    restart: unless-stopped
    networks:
      - demyx
    depends_on:
      - db_${DEMYX_APP_ID}
    environment:
      - WORDPRESS_DOMAIN=\${DEMYX_APP_DOMAIN}
      - WORDPRESS_UPLOAD_LIMIT=\${DEMYX_APP_UPLOAD_LIMIT}
      - WORDPRESS_PHP_MEMORY=\${DEMYX_APP_PHP_MEMORY}
      - WORDPRESS_PHP_MAX_EXECUTION_TIME=\${DEMYX_APP_PHP_MAX_EXECUTION_TIME}
      - WORDPRESS_PHP_OPCACHE=\${DEMYX_APP_PHP_OPCACHE}
      - WORDPRESS_PHP_PM=\${DEMYX_APP_PHP_PM}
      - WORDPRESS_PHP_PM_MAX_CHILDREN=\${DEMYX_APP_PHP_PM_MAX_CHILDREN}
      - WORDPRESS_PHP_PM_START_SERVERS=\${DEMYX_APP_PHP_PM_START_SERVERS}
      - WORDPRESS_PHP_PM_MIN_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS}
      - WORDPRESS_PHP_PM_MAX_SPARE_SERVERS=\${DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS}
      - WORDPRESS_PHP_PM_PROCESS_IDLE_TIMEOUT=\${DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT}
      - WORDPRESS_PHP_PM_MAX_REQUESTS=\${DEMYX_APP_PHP_PM_MAX_REQUESTS}
      - TZ=$TZ
      $DEMYX_YML_RUN_CREDENTIALS
    volumes:
      - wp_${DEMYX_APP_ID}:/demyx
      - wp_${DEMYX_APP_ID}_log:/var/log/demyx
  db_${DEMYX_APP_ID}:
    image: demyx/mariadb:edge
    cpus: \${DEMYX_APP_DB_CPU}
    mem_limit: \${DEMYX_APP_DB_MEM}
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - wp_${DEMYX_APP_ID}_db:/demyx
      - wp_${DEMYX_APP_ID}_log:/var/log/demyx
    environment:
      - MARIADB_DOMAIN=\${DEMYX_APP_DOMAIN}
      - MARIADB_DATABASE=\${WORDPRESS_DB_NAME}
      - MARIADB_USERNAME=\${WORDPRESS_DB_USER}
      - MARIADB_PASSWORD=\${WORDPRESS_DB_PASSWORD}
      - MARIADB_ROOT_PASSWORD=\${MARIADB_ROOT_PASSWORD}
      - MARIADB_DEFAULT_CHARACTER_SET=\${MARIADB_DEFAULT_CHARACTER_SET}
      - MARIADB_CHARACTER_SET_SERVER=\${MARIADB_CHARACTER_SET_SERVER}
      - MARIADB_COLLATION_SERVER=\${MARIADB_COLLATION_SERVER}
      - MARIADB_KEY_BUFFER_SIZE=\${MARIADB_KEY_BUFFER_SIZE}
      - MARIADB_MAX_ALLOWED_PACKET=\${MARIADB_MAX_ALLOWED_PACKET}
      - MARIADB_TABLE_OPEN_CACHE=\${MARIADB_TABLE_OPEN_CACHE}
      - MARIADB_SORT_BUFFER_SIZE=\${MARIADB_SORT_BUFFER_SIZE}
      - MARIADB_NET_BUFFER_SIZE=\${MARIADB_NET_BUFFER_SIZE}
      - MARIADB_READ_BUFFER_SIZE=\${MARIADB_READ_BUFFER_SIZE}
      - MARIADB_READ_RND_BUFFER_SIZE=\${MARIADB_READ_RND_BUFFER_SIZE}
      - MARIADB_MYISAM_SORT_BUFFER_SIZE=\${MARIADB_MYISAM_SORT_BUFFER_SIZE}
      - MARIADB_SERVER_ID=\${MARIADB_SERVER_ID}
      - MARIADB_INNODB_DATA_FILE_PATH=\${MARIADB_INNODB_DATA_FILE_PATH}
      - MARIADB_INNODB_BUFFER_POOL_SIZE=\${MARIADB_INNODB_BUFFER_POOL_SIZE}
      - MARIADB_INNODB_LOG_FILE_SIZE=\${MARIADB_INNODB_LOG_FILE_SIZE}
      - MARIADB_INNODB_LOG_BUFFER_SIZE=\${MARIADB_INNODB_LOG_BUFFER_SIZE}
      - MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=\${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}
      - MARIADB_INNODB_LOCK_WAIT_TIMEOUT=\${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}
      - MARIADB_INNODB_USE_NATIVE_AIO=\${MARIADB_INNODB_USE_NATIVE_AIO}
      - MARIADB_READ_BUFFER=\${MARIADB_READ_BUFFER}
      - MARIADB_WRITE_BUFFER=\${MARIADB_WRITE_BUFFER}
      - MARIADB_MAX_CONNECTIONS=\${MARIADB_MAX_CONNECTIONS}
      - TZ=$TZ
volumes:
  wp_${DEMYX_APP_ID}:
    name: wp_${DEMYX_APP_ID}
  wp_${DEMYX_APP_ID}_db:
    name: wp_${DEMYX_APP_ID}_db
  wp_${DEMYX_APP_ID}_log:
    name: wp_${DEMYX_APP_ID}_log
networks:
  demyx:
    name: demyx" > "$DEMYX_APP_PATH"/docker-compose.yml
