services:
  - name: plex
    port: 32400
    image: linuxserver/plex
    extra_docker_args:
      network_mode: host
    mapped_ports:
      - "32400:32400"
      - "1900:1900"
      - "3005:3005"
      - "5353:5353"
      - "8324:8324"
      - "32410:32410"
      - "32412:32412"
      - "32413:32413"
      - "32414:32414"
      - "32469:32469"
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=Europe/London
      - VERSION=latest
    volumes:
      - ${MOUNT_POINT}/plex/config:/config
      - ${MOUNT_POINT}/media:/data
      - ${MOUNT_POINT}/plex/logs:/config/Library/Application Support/Plex Media Server/Logs
      - ${MOUNT_POINT}/plex/transcode:/transcode
  - name: plexpy
    port: 8181
    image: linuxserver/plexpy
    mapped_ports:
      - "8181:8181"
    lan: plexnet
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=Europe/London
    volumes:
      - ${MOUNT_POINT}/plex/config:/config
      - ${MOUNT_POINT}/plex/logs:/logs:ro
  - name: radarr
    port: 7878
    image: linuxserver/radarr
    mapped_ports:
      - "7878:7878"
    lan: plexnet
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=Europe/London
    volumes:
      - ${MOUNT_POINT}/radarr:/config
      - ${MOUNT_POINT}/media/Downloads/completed:/data/completed
      - ${MOUNT_POINT}/media/Movies:/movies
  - name: sonarr
    port: 8989
    image: linuxserver/sonarr
    mapped_ports:
      - "8989:8989"
    lan: plexnet
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=Europe/London
    volumes:
      - ${MOUNT_POINT}/sonarr:/config
      - ${MOUNT_POINT}/media/Downloads/completed:/data/completed
      - ${MOUNT_POINT}/media/TV Shows:/tv
  - name: transmission
    port: 9091
    image: haugene/transmission-openvpn
    extra_docker_args:
      cap_add:
        - NET_ADMIN
      privileged: true
    mapped_ports:
      - "9091:9091"
    lan: plexnet
    environment:
      - OPENVPN_PROVIDER=${VPN_PROVIDER}
      - OPENVPN_CONFIG=${VPN_CONFIG}
      - OPENVPN_USERNAME=${VPN_USERNAME}
      - OPENVPN_PASSWORD=${VPN_PASSWORD}
      - OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60
      - PGID=1000
      - PUID=1000
    volumes:
      - ${MOUNT_POINT}/media/Downloads:/data
      - /etc/localtime:/etc/localtime:ro
  - name: jackett
    port: 9117
    image: linuxserver/jackett
    mapped_ports:
      - "9117:9117"
    lan: plexnet
    environment:
      - PGID=1000
      - PUID=1000
      - TZ=Europe/London
    volumes:
      - ${MOUNT_POINT}/jackett:/config
      - ${MOUNT_POINT}/jackett/downloads/downloads
  - name: wiki
    port: 8037
    image: solidnerd/bookstack:0.18.3
    mapped_ports:
      - "8037:80"
    lan: wikinet
    environment:
      - DB_HOST=wikidb:3306
      - DB_DATABASE=${WIKI_DB}
      - DB_USERNAME=${WIKI_DB_USER}
      - DB_PASSWORD=${WIKI_DB_PASSWORD}
    volumes:
      - ${MOUNT_POINT}/wiki/uploads:/var/www/bookstack/public/uploads
      - ${MOUNT_POINT}/wiki/storage-uploads:/var/www/bookstack/public/storage
  - name: unbound
    image: mvance/unbound
    mapped_ports:
      - 53:53/udp
    lan: plexnet
    volumes:
      - ${MOUNT_POINT}/unbound/a-records.conf:/opt/unbound/etc/unbound/a-records.conf:ro
  - name: wikidb
    image: mysql:5.7.12
    lan: wikinet
    environment:
      - MYSQL_ROOT_PASSWORD=${WIKI_DB_PASSWORD}
      - MYSQL_DATABASE=${WIKI_DB}
      - MYSQL_USER=${WIKI_DB_USER}
      - MYSQL_PASSWORD=${WIKI_DB_USER_PASSWORD}
    volumes:
      - ${MOUNT_POINT}/wikidb:/var/lib/mysql
networks:
  - plexnet
  - wikinet
