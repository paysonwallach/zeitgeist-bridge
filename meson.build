project(
  'com.paysonwallach.zeitgeist.bridge',
  'vala',
  'c',
  license: 'GPL-3.0',
  meson_version: '>=0.55.0',
  version: '0.1.0'
)

vala = meson.get_compiler('vala')

add_global_arguments(
  ['-DG_LOG_DOMAIN="com.paysonwallach.zeitgeist.bridge"'],
  language:'c'
)

gee_dep = dependency('gee-0.8')
glib_dep = dependency('glib-2.0')
glib_json_dep = dependency('json-glib-1.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
zeitgeist_dep = dependency('zeitgeist-2.0')
posix_dep = vala.find_library('posix')

executable(
  meson.project_name(),
  files(
    'src/ExtensionProxy.vala',
    'src/Main.vala',
    'src/Message.vala',
    'src/Utils.vala'
  ),
  dependencies: [
    gee_dep,
    glib_dep,
    glib_json_dep,
    gio_dep,
    gio_unix_dep,
    zeitgeist_dep,
    posix_dep,
  ],
  install: true
)

meson.add_install_script(
  'meson/post_install.py',
  get_option('browsers')
)
