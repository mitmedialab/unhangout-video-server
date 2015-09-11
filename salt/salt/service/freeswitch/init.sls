{% from 'vars.jinja' import server_id, server_env, server_encryption_password, freeswitch_git_checkout, freeswitch_git_revision, freeswitch_ip, freeswitch_default_password, freeswitch_conference_unhangout_user_password, freeswitch_conference_unhangout_moderator_password with context %}

include:
  - repo.freeswitch

freeswitch-group:
  group.present:
    - name: freeswitch
    - system: True

freeswitch-user:
  user.present:
    - name: freeswitch
    - system: True
    - gid_from_name: True
    - fullname: "FreeSWITCH system user"
    - createhome: False
    - require:
      - group: freeswitch-group

freeswitch-repo-deps-setenv:
  environ.setenv:
    - value:
        DEBIAN_FRONTEND: none
        APT_LISTCHANGES_FRONTEND: none
    - update_minion: True
    # Not the cleanest test, but it prevents the state from unnecessarily
    # re-executing.
    - unless: test -d /usr/share/doc/freeswitch-video-deps-most

freeswitch-video-deps-package:
  pkg.installed:
    - name: freeswitch-video-deps-most
    - require:
      - environ: freeswitch-repo-deps-setenv

freeswitch-repo-deps-rmenv:
  environ.setenv:
    - false_unsets: True
    - value:
        DEBIAN_FRONTEND: False
        APT_LISTCHANGES_FRONTEND: False
    - update_minion: True
    - require:
      - pkg: freeswitch-video-deps-package
    # Not the cleanest test, but it prevents the state from unnecessarily
    # re-executing.
    - unless: test -d /usr/share/doc/freeswitch-video-deps-most

freeswitch-git-checkout:
  git.latest:
    - name: https://freeswitch.org/stash/scm/fs/freeswitch.git
    - rev: {{ freeswitch_git_revision }}
    - target: {{ freeswitch_git_checkout }}
    - require:
      - environ: freeswitch-repo-deps-rmenv

freeswitch-build:
  cmd.script:
    - source: salt://service/freeswitch/build.sh
    - cwd: {{ freeswitch_git_checkout }}
    - use_vt: True
    - require:
      - group: freeswitch-group
      - user: freeswitch-user
    - onchanges:
      - git: freeswitch-git-checkout

/usr/local/freeswitch/certs:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 750
    - require:
      - cmd: freeswitch-build

{% for cert in ['agent', 'cafile', 'wss'] %}
/usr/local/freeswitch/certs/{{ cert }}.pem:
  file.managed:
    - source: salt://service/freeswitch/certs/{{ server_id }}/{{ cert }}.pem
    - user: root
    - group: freeswitch
    - mode: 640
    - require:
      - group: freeswitch-group
      - file: /usr/local/freeswitch/certs
{% endfor %}

/usr/local/freeswitch/db:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/log:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/log/cdr-csv:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - file: /usr/local/freeswitch/log

/usr/local/freeswitch/log/xml_cdr:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - file: /usr/local/freeswitch/log

/usr/local/freeswitch/recordings:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/run:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/storage:
  file.directory:
    - user: freeswitch
    - group: freeswitch
    - dir_mode: 755
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/vars.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/vars.xml.jinja
    - template: jinja
    - context:
      freeswitch_ip: {{ freeswitch_ip }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/acl.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/acl.conf.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/conference.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/conference.conf.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/conference_layouts.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/conference_layouts.conf.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/event_socket.conf.xml.jinja
    - template: jinja
    - context:
      server_encryption_password: {{ server_encryption_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/modules.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/modules.conf.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/sofia.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/sofia.conf.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/autoload_configs/verto.conf.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/autoload_configs/verto.conf.xml.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
      freeswitch_ip: {{ freeswitch_ip }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/dialplan/default.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/dialplan/default.xml.jinja
    - template: jinja
    - context:
      freeswitch_default_password: {{ freeswitch_default_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/directory/default.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/directory/default.xml.jinja
    - template: jinja
    - context:
      freeswitch_conference_unhangout_user_password: {{ freeswitch_conference_unhangout_user_password }}
      freeswitch_conference_unhangout_moderator_password: {{ freeswitch_conference_unhangout_moderator_password }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/freeswitch.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/freeswitch.xml
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

/usr/local/freeswitch/conf/sip_profiles/internal.xml:
  file.managed:
    - source: salt://service/freeswitch/conf/sip_profiles/internal.xml.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
      freeswitch_ip: {{ freeswitch_ip }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

# TODO: Re-enable this when a mute png has been added.
#/usr/local/freeswitch/images/unhangout-video-mute.png:
#  file.managed:
#    - source: salt://service/freeswitch/images/unhangout-video-mute.png
#    - user: root
#    - group: root
#    - mode: 644
#    - require:
#      - cmd: freeswitch-build

/usr/local/freeswitch/images/HelveticaNeue-Medium.ttf:
  file.managed:
    - source: salt://service/freeswitch/images/HelveticaNeue-Medium.ttf
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: freeswitch-build

symlink-fs-cli-to-path:
  file.symlink:
    - name: /usr/local/bin/fs_cli
    - target: /usr/local/freeswitch/bin/fs_cli
    - require:
      - cmd: freeswitch-build

/etc/sysctl.d/vid.conf:
  file.managed:
    - source: salt://etc/sysctl.d/vid.conf
    - user: root
    - group: root
    - mode: 644

{% if server_env != 'production' %}
/etc/sysctl.d/core-dump.conf:
  file.managed:
    - source: salt://etc/sysctl.d/core-dump.conf
    - user: root
    - group: root
    - mode: 644
{% endif %}

# This is a dummy file that allows systemd to manage the service using Salt's
# debian_service provider.
/etc/init.d/freeswitch:
  file.managed:
    - source: salt://etc/init.d/freeswitch
    - user: root
    - group: root
    - mode: 755

/lib/systemd/system/freeswitch.service:
  file.managed:
    - source: salt://service/freeswitch/systemd-freeswitch.service.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
    - user: root
    - group: root
    - mode: 644

freeswitch-service:
  service.running:
    - name: freeswitch
    - enable: true
    - require:
      - file: /lib/systemd/system/freeswitch.service
      - file: /etc/init.d/freeswitch
    - watch:
      {% for cert in ['agent', 'cafile', 'wss'] %}
      - file: /usr/local/freeswitch/certs/{{ cert }}.pem
      {% endfor %}
      - file: /usr/local/freeswitch/conf/vars.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/acl.conf.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/conference.conf.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/conference_layouts.conf.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/event_socket.conf.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml
      - file: /usr/local/freeswitch/conf/autoload_configs/verto.conf.xml
      - file: /usr/local/freeswitch/conf/dialplan/default.xml
      - file: /usr/local/freeswitch/conf/directory/default.xml
      - file: /usr/local/freeswitch/conf/freeswitch.xml
      - file: /usr/local/freeswitch/conf/sip_profiles/internal.xml
      # TODO: Re-enable this when a mute png has been added.
      #- file: /usr/local/freeswitch/images/unhangout-video-mute.png
      - file: /usr/local/freeswitch/images/HelveticaNeue-Medium.ttf
      - cmd: freeswitch-build

extend:
  freeswitch-repo:
    pkgrepo.managed:
      - require_in:
        - pkg: freeswitch-video-deps-package
