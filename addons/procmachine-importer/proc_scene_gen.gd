# This class can be used without instantiating the node
# ..or adding to the tree using ProcImport.*
extends Node
class_name ProcImport

static var size : int = 20
static var radius : float = size / 2
static var scale : float = 10.00 # 1metre

static func GeneratePROCMachineItemsScene(
	jString: String,
	width: float = 514.350,
	height: float = 1066.8,
	playfield = true,
	prswitches = true,
	prcoils = true,
	prleds = true,
	prlamps = true,
	prgi = true):
	
	var json = JSON.new()
	var error = json.parse(jString);	
	if error == OK:
		var data_received = json.data
		
		var scene = Node3D.new();
		scene.name = "ProcMachineNode3D"	
	
		var cam3d = Camera3D.new()
		cam3d.fov = 45		
		cam3d.name = "Camera3D"
		scene.add_child(cam3d)
		cam3d.owner = scene		
		cam3d.position.x = width / 2
		cam3d.position.y = 270
		cam3d.position.z = height + 200		
		cam3d.rotation.x = -32
		
		if(playfield):
			var csgPf = CreatePlayfield(width, height)
			scene.add_child(csgPf)
			csgPf.owner = scene			
		
		if prleds:			
			var node = ProcImport.CreateProcMachineItemsNode(
				scene, "PRLeds", data_received["PRLeds"],true, Color.CHARTREUSE)
		
		if prswitches:		
			var node = ProcImport.CreateProcMachineItemsNode(
			scene, "PRSwitches", data_received["PRSwitches"],false, Color.DEEP_PINK)	
		
		if prcoils:
			var node = ProcImport.CreateProcMachineItemsNode(
			scene, "PRCoils", data_received["PRCoils"],false, Color.AQUA)	
				
		if prlamps:	
			var node = ProcImport.CreateProcMachineItemsNode(
			scene, "PRLamps", data_received["PRLamps"],true, Color.GREEN)	
				
		if prgi:	
			var node = ProcImport.CreateProcMachineItemsNode(
				scene, "PRGI", data_received["PRGI"],true, Color.ORANGE)	
			
		var pkedScene = PackedScene.new()
		var pkScened = pkedScene.pack(scene)
		if pkScened != OK:
			push_error("An error occurred while packing the scene")	
			return null
		else:
			return pkedScene
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", jString, " at line ", json.get_error_line())															

# creates a cylinder, removes radius from pos	
static func CreateCylinder(
	mat:Material,
	name:String,
	xpos:float,
	zpos:float):
	var cyl = CSGCylinder3D.new()
	cyl.material = mat
	cyl.name = name
	cyl.sides = 32
	cyl.height = 2
	cyl.radius = radius
	cyl.position.x = (xpos - radius)
	cyl.position.z = (zpos - radius) 
	return cyl

# creates a box, add radius to pos
static func CreateBox(
	mat:Material,
	name:String,
	xpos:float,
	zpos:float):
	var box = CSGBox3D.new()
	box.material = mat
	box.name = name
	box.size.z = (size)
	box.size.y = (2)
	box.size.x = (size)
	box.position.x = (xpos + radius)
	box.position.z = (zpos + radius)
	return box
	
static func CreatePlayfield(width : float = 514.350, height : float = 1066.8):
	var csgPf = CSGBox3D.new()
	var pfMat = StandardMaterial3D.new()
	pfMat.albedo_color = Color.SADDLE_BROWN
	csgPf.material = pfMat
	csgPf.name = "PlayfieldCSGBox"
	# set the width height and thickness
	csgPf.size.x = width
	csgPf.size.y = 12.5
	csgPf.size.z = height
	#offset the playfield by half, starts center 0,0
	csgPf.position.x = width / 2
	csgPf.position.z = height / 2
	csgPf.position.y = -(12.5 / 2)
	return csgPf

static func CreateProcMachineItemsNode(
	owner: Node3D,
	name:String,
	items: Array,
	cylinder: bool = false,
	color:Color = Color.DARK_ORCHID):
	var node = Node3D.new()
	node.name = name
	owner.add_child(node)
	node.owner = owner
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	for key in items:
		if cylinder:
			var obj = ProcImport.CreateCylinder(mat, key.Name, key.XPos, key.YPos)
			node.add_child(obj)
			obj.owner = owner
		else:
			var obj = ProcImport.CreateBox(mat, key.Name, key.XPos, key.YPos)
			node.add_child(obj)
			obj.owner = owner
	return node

static func GetScaledSize(size) -> float:
	return float(size / scale)
