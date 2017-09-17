unbound:
 file.managed:
   - name: /l1-za/unbound/a-records.conf
   - source: salt://unbound.conf
   - template: jinja
   - context:
     services: {{pillar.get('services', {})}}
