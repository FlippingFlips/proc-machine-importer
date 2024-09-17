@tool
extends EditorImportPlugin

enum Presets { DEFAULT }
var size: int = 20
var radius: int = size / 2

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
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	var jString = file.get_as_text();
	var json = JSON.new()
	var error = json.parse(jString);
	
	var scene = Node3D.new();
	scene.name = "ProcMachineNode3D"	
	
	var cam3d = Camera3D.new()
	cam3d.fov = 45		
	cam3d.name = "Camera3D"
	scene.add_child(cam3d)
	cam3d.owner = scene
	
	if options.generate_playfield:
		var csgPf = CSGBox3D.new()
		var pfMat = StandardMaterial3D.new()
		pfMat.albedo_color = Color.SADDLE_BROWN
		csgPf.material = pfMat
		csgPf.name = "PlayfieldCSGBox"
		# set the width height and thickness
		csgPf.size.x = options.playfield_width
		csgPf.size.y = 12.5
		csgPf.size.z = options.playfield_height
		#offset the playfield by half, starts center 0,0
		csgPf.position.x = options.playfield_width / 2
		csgPf.position.z = options.playfield_height / 2		
		csgPf.position.y = -(12.5 / 2)
		scene.add_child(csgPf)
		csgPf.owner = scene;	
		
		cam3d.position.x = csgPf.size.x / 2
		cam3d.position.y = 270
		cam3d.position.z = csgPf.size.z + 200		
		cam3d.rotation.x = -32	
	
	if error == OK:
		var data_received = json.data			
			
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.CHARTREUSE
			
		if options.include_prleds:
			var ledNode = Node3D.new()
			ledNode.name = "LEDS"
			scene.add_child(ledNode)	
			ledNode.owner = scene							
			for key in data_received["PRLeds"]:			
				var box = CSGCylinder3D.new()
				box.material = mat
				box.name = key.Name
				box.sides = 32
				box.height = 2
				box.radius = radius
				box.position.x = (key.XPos - radius)
				box.position.z = (key.YPos - radius)
				ledNode.add_child(box)
				box.owner = scene
		
		if options.include_prswitches:		
			var switchesNode = Node3D.new()
			switchesNode.name = "SWITCHES"
			scene.add_child(switchesNode)	
			switchesNode.owner = scene				
			
			mat = StandardMaterial3D.new()
			mat.albedo_color = Color.DEEP_PINK
			for key in data_received["PRSwitches"]:			
				var box = CSGBox3D.new()
				box.material = mat
				box.name = key.Name
				box.size.z = size
				box.size.y = 2
				box.size.x = size
				box.position.x = (key.XPos + radius)
				box.position.z = (key.YPos + radius)
				switchesNode.add_child(box)
				box.owner = scene			
		
		if options.include_prcoils:	
			var driversNode = Node3D.new()
			driversNode.name = "DRIVERS"
			scene.add_child(driversNode)	
			driversNode.owner = scene				
			
			mat = StandardMaterial3D.new()
			mat.albedo_color = Color.AQUA
			
			for key in data_received["PRCoils"]:			
				var box = CSGBox3D.new()
				box.material = mat
				box.name = key.Name
				box.size.z = size
				box.size.y = 2
				box.size.x = size
				box.position.x = (key.XPos + radius)
				box.position.z = (key.YPos + radius)
				driversNode.add_child(box)
				box.owner = scene
				
		if options.include_prlamps:	
			var lampsNode = Node3D.new()
			lampsNode.name = "LAMPS"
			scene.add_child(lampsNode)	
			lampsNode.owner = scene				
			mat = StandardMaterial3D.new()
			mat.albedo_color = Color.GREEN			
			for key in data_received["PRLamps"]:			
				var box = CSGCylinder3D.new()
				box.material = mat
				box.name = key.Name
				box.sides = 32
				box.height = 2
				box.radius = radius
				box.position.x = (key.XPos - radius)
				box.position.z = (key.YPos - radius)
				lampsNode.add_child(box)
				box.owner = scene
				
		if options.include_prgi:	
			var giNode = Node3D.new()
			giNode.name = "GI"
			scene.add_child(giNode)	
			giNode.owner = scene				
			mat = StandardMaterial3D.new()
			mat.albedo_color = Color.ORANGE
			for key in data_received["PRGI"]:			
				var box = CSGCylinder3D.new()
				box.material = mat
				box.name = key.Name
				box.sides = 32
				box.height = 2
				box.radius = radius
				box.position.x = (key.XPos - radius)
				box.position.z = (key.YPos - radius)
				giNode.add_child(box)
				box.owner = scene				
	else:	
		print("JSON Parse Error: ", json.get_error_message(), " in ", jString, " at line ", json.get_error_line())			
	
	var packedScene = PackedScene.new()
	var result = packedScene.pack(scene)
	if result != OK:
		push_error("An error occurred while saving the scene to disk.")			

	return ResourceSaver.save(packedScene, "%s.%s" % [save_path, _get_save_extension()])
