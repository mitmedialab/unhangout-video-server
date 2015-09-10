{% from 'vars.jinja' import server_env, ssh_pubkeys_root, server_encryption_password, freeswitch_ip with context %}

{% for user, data in ssh_pubkeys_root.iteritems() %}
sshkey-{{ user }}:
  ssh_auth:
    - present
    - user: root
    - enc: {{ data.enc|default('ssh-rsa') }}
    - name: {{ data.key }}
    - comment: {{ user }}
{% endfor %}

/root/.bashrc.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/root/.bashrc.d/freeswitch.sh:
  file.managed:
    - source: salt://auth/root/bashrc.d/freeswitch.sh
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /root/.bashrc.d

/root/.fs_cli_conf:
  file.managed:
    - template: jinja
    - context:
      server_encryption_password: {{ server_encryption_password }}
    - source: salt://auth/root/fs_cli_conf.jinja
    - user: root
    - group: root
    - mode: 644

/root/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/root/bin/fs:
  file.managed:
    - source: salt://auth/root/bin/fs.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
    - user: root
    - group: root
    - mode: 755

{% if server_env != 'production' %}
/root/bin/fs-debug:
  file.managed:
    - source: salt://auth/root/bin/fs-debug
    - user: root
    - group: root
    - mode: 755
{% endif %}

