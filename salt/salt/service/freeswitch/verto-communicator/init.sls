{% from 'vars.jinja' import
  freeswitch_git_checkout,
  server_env,
  server_type
with context %}

include:
  - service.npm
  - service.httpd
  - service.freeswitch

verto-communicator-node-packages:
  npm.installed:
    - pkgs:
      - bower
      - grunt
      - grunt-cli
    - require:
      - pkg: npm-package

npm-bootstrap-verto-communicator:
  npm.bootstrap:
    - name: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - require:
      - npm: verto-communicator-node-packages
{% if server_type != 'vagrant' %}
    - watch:
      - git: freeswitch-git-checkout
{% endif %}

bower-bootstrap-verto-communicator:
  cmd.run:
    - name: /usr/local/bin/bower --allow-root --config.interactive=false install -F
    - cwd: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - unless: test -d {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/bower_components
    - use_vt: True
    - require:
      - npm: npm-bootstrap-verto-communicator
{% if server_type != 'vagrant' %}
    - watch:
      - git: freeswitch-git-checkout
{% endif %}

{% if server_env == 'production' %}
build-verto-communicator:
  cmd.run:
    - name: /usr/local/bin/grunt build
    - cwd: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - unless: test -d /var/www/html/verto-communicator
    - use_vt: True
    - require:
      - cmd: bower-bootstrap-verto-communicator
    - watch:
      - git: freeswitch-git-checkout

deploy-verto-communicator:
  file.rename:
    - name: /var/www/html/verto-communicator
    - source: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/dist
    - require:
      - cmd: build-verto-communicator
    - watch:
      - git: freeswitch-git-checkout

{% else %}

/usr/local/bin/start-conference.sh:
  file.managed:
    - source: salt://service/freeswitch/verto-communicator/start-conference.sh.jinja
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: bower-bootstrap-verto-communicator

/usr/local/bin/rebuild-conference.sh:
  file.managed:
    - source: salt://service/freeswitch/verto-communicator/rebuild-conference.sh.jinja
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: bower-bootstrap-verto-communicator
{% endif %}

