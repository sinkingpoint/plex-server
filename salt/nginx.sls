nginx:
  pkg.installed:
    - name: nginx

  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: nginx
      {% for service in pillar.get('services', {}) %}
      - file: {{service['name']}}-enabled
      {% endfor %}

{% for service in pillar.get('services', {}) %}
{{service['name']}}-available:
  file.managed:
    - name: /etc/nginx/sites-available/{{service['name']}}
    - source: salt://nginx-proxy.conf
    - template: jinja
    - context:
      service_name: {{service['name']}}
      service_port: {{service['port']}}
    - require:
       - pkg: nginx

{{service['name']}}-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{service['name']}}
    - target: /etc/nginx/sites-available/{{service['name']}}
{% endfor %}


