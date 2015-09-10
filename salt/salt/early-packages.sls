# This is the very first state executed, mostly because we want these critical
# packages available as soon as possible.
early-packages:
  pkg.installed:
    - order: 1
    - pkgs:
      - curl
      # There's some ordering bug that throws an error when installing this
      # package as a dependency for the freeswitch-video-deps-most package
      # Installing it here solves the issue, and seems a reasonable
      # workaround.
      # TODO: Is this still needed?
      - libgvc6
      - perl
      - wget

