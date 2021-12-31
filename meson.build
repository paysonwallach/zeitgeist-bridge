project(
  'com.paysonwallach.zeitgeist.bridge',
  'vala',
  'c',
  license: 'GPL-3.0',
  meson_version: '>=0.56.0',
  version: '0.1.0'
)

vala = meson.get_compiler('vala')

vapi_dir = join_paths(meson.source_root(), 'vapi')

gee_dep = dependency('gee-0.8')
glib_dep = dependency('glib-2.0')
glib_json_dep = dependency('json-glib-1.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
zeitgeist_dep = dependency('zeitgeist-2.0')
posix_dep = vala.find_library('posix')

conf = configuration_data()
conf.set_quoted('APPLICATION_ID', meson.project_name())
conf.set_quoted('APPLICATION_NAME', run_command('sh', '-c', 'cat @0@ | jq -r ".name"'.format(join_paths(meson.project_source_root(), 'package.json'))).stdout().strip())
conf.set_quoted('APPLICATION_DESCRIPTION', run_command('sh', '-c', 'cat @0@ | jq -r ".description"'.format(join_paths(meson.project_source_root(), 'package.json'))).stdout().strip())
conf.set_quoted('API_VERSION', 'v2')

config_h = configure_file(
output: 'config.h',
  configuration: conf
)

config_dep = declare_dependency(
  dependencies: vala.find_library('config', dirs: vapi_dir),
  sources: config_h
)

add_project_arguments(
  ['-DG_LOG_DOMAIN="@0@"'.format(meson.project_name())],
  language:'c'
)

executable(
  meson.project_name(),
  files(
    'src/ExtensionProxy.vala',
    'src/Main.vala',
    'src/Protocol.vala',
    'src/Utils/Serializable.vala'
  ),
  dependencies: [
    config_dep,
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
