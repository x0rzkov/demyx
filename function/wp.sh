# Demyx
# https://demyx.sh

demyx_wp() {
    demyx_app_config
    
    if [[ "$DEMYX_TARGET" = all ]]; then
        cd "$DEMYX_WP" || exit
        for i in *
        do
            demyx wp "$i" "$@"
        done
    elif [[ "$DEMYX_APP_TYPE" = wp ]]; then
        # Will remove this backwards compability in January 1st, 2020
        DEMYX_WP_CLI=demyx/wordpress:cli
        [[ "$DEMYX_APP_WP_IMAGE" = demyx/nginx-php-wordpress ]] && DEMYX_WP_CLI=wordpress:cli
        [[ "$DEMYX_APP_WP_IMAGE" = demyx/wordpress:bedrock ]] && DEMYX_GLOBAL_WP_VOLUME=/demyx/web

        demyx_execute -v docker run -t --rm \
            --network=demyx \
            --volumes-from="$DEMYX_APP_WP_CONTAINER" \
            --workdir="$DEMYX_GLOBAL_WP_VOLUME" \
            "$DEMYX_WP_CLI" "$@"
    else
        demyx_die --not-found
    fi
}
