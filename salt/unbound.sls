unbound:
 file.managed:
   - name: /l1-za/unbound/a-records.conf
   - source: salt://unbound.conf
   - template: jinja
   - context:
       hostname: {{salt['network.get_hostname']()}}
       services: {{pillar.get('services', {})}}
