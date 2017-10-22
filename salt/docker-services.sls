/opt/media-compose/docker-compose.yml:
  file.managed:
    - source: salt://docker-compose.yml
    - template: jinja

docker-services:
  module.run:
    - name: dockercompose.up
    - path: /opt/media-compose
