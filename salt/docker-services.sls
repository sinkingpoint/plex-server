/opt/media-compose/docker-compose.yml:
  file.managed:
    - source: salt://docker-compose.yml
    - template: jinja
    - context:
        services: {{pillar.get('services', {})}}
        networks: {{pillar.get('networks', {})}}

docker-services:
  module.run:
    - name: dockercompose.up
    - path: /opt/media-compose
