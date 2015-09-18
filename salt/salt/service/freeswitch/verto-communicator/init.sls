{% from 'vars.jinja' import freeswitch_git_checkout with context %}

include:
  - service.npm
  - service.httpd
  - service.freeswitch

verto-communicator-packages:
  npm.installed:
    - pkgs:
      - bower
      - grunt
      - grunt-cli

build-verto-communicator:
  cmd.run:
    - name: /usr/bin/npm install && /usr/local/bin/bower --allow-root --config.interactive=false install && /usr/local/bin/grunt build
    - cwd: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator
    - unless: test -d /var/www/html/verto-communicator
    - use_vt: True
    - require:
      - git: freeswitch-git-checkout
      - npm: verto-communicator-packages

deploy-verto-communicator:
  file.rename:
    - name: /var/www/html/verto-communicator
    - source: {{ freeswitch_git_checkout }}/html5/verto/verto_communicator/dist
    - require:
      - cmd: build-verto-communicator
