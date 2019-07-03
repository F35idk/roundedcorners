gala_roundedcorners_sources = [
	'Main.vala',
	'Settings.vala',
]

gala_roundedcorners_lib = shared_library(
	'gala-roundedcorners',
	gala_roundedcorners_sources,
	dependencies: [gala_dep, gala_base_dep],
	include_directories: config_inc_dir,
	install: true,
	install_dir: plugins_dir,
	install_rpath: mutter_typelib_dir,
)

install_data(
	'shaders/BorderlessCornerEffect.frag',
    'shaders/BorderedCornerEffect.frag',
	install_dir: pkgdata_dir,
)
