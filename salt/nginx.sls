nginx:
  pkg.installed:
    - name: nginx

  service.running:
    - enable: True
    - reload: True
    - watch:
      - pkg: nginx
      {% for service in pillar.get('services', {}) %}
      {%- if 'port' in service: %}
      - file: {{service['name']}}-lan-available
      - file: {{service['name']}}-sinkingpoint-available
      {%- endif %}
      {% endfor %}

{% for service in pillar.get('services', {}) %}
{%- if 'port' in service: %}
{{service['name']}}-lan-available:
  file.managed:
    - name: /etc/nginx/sites-available/{{service['name']}}-lan
    - source: salt://nginx-proxy.conf
    - template: jinja
    - context:
      service_name: {{service['name']}}.lan
      service_port: {{service['port']}}
    - require:
       - pkg: nginx
{{service['name']}}-sinkingpoint-available:
  file.managed:
    - name: /etc/nginx/sites-available/{{service['name']}}-sinkingpoint
    - source: salt://nginx-proxy.conf
    - template: jinja
    - context:
      service_name: {{service['name']}}.sinkingpoint.com
      service_port: {{service['port']}}
    - require:
       - pkg: nginx

{{service['name']}}-lan-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{service['name']}}-lan
    - target: /etc/nginx/sites-available/{{service['name']}}-lan

{{service['name']}}-sinkingpoint-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{service['name']}}-sinkingpoint
    - target: /etc/nginx/sites-available/{{service['name']}}-sinkingpoint
{%- endif %}
{% endfor %}


