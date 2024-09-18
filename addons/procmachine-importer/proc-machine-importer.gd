@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name():
	return "demos.machinejson"
	
func _get_recognized_extensions():
	return ["json"]	

func _get_visible_name():
	return "PROC Node3D Scene"

func _get_save_extension():
	return "tscn"

func _get_resource_type():
	return "PackedScene"

func _get_preset_count():
	return Presets.size()

func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return [{
					   "name": "generate_playfield",
					   "default_value": true
					},
					{
					   "name": "playfield_width",
					   "default_value": 514.350
					},
					{
					   "name": "playfield_height",
					   "default_value": 1066.800
					},
					{
					   "name": "include_prswitches",
					   "default_value": true
					},
					{
					   "name": "include_prleds",
					   "default_value": true
					},
					{
					   "name": "include_prcoils",
					   "default_value": true
					},
					{
					   "name": "include_prlamps",
					   "default_value": false
					},
					{
					   "name": "include_prgi",
					   "default_value": false
					}
					]
		_:
			return []

func _get_option_visibility(path, option_name, options):
	return true
	
func _get_priority():
	return 2
	
func _get_import_order():
	return 2

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	
	# open the json file and get the string contents
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()	
	var jString = file.get_as_text();
	
	# use the static method to create a playfield scene with machine items
	var packedScene = ProcImport.GeneratePROCMachineItemsScene(
		jString, options.playfield_width, options.playfield_height, options.generate_playfield, options.include_prswitches,
		options.include_prcoils, options.include_prleds, options.include_prlamps,options.include_prgi);		

	# Save it to disk
	return ResourceSaver.save(packedScene, "%s.%s" % [save_path, _get_save_extension()])
