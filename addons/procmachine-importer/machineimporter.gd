@tool
extends EditorPlugin
var machine_plugin

func _enter_tree():
	machine_plugin = preload("proc-machine-importer.gd").new()
	add_import_plugin(machine_plugin)

func _exit_tree():
	remove_import_plugin(machine_plugin)
	machine_plugin = null
