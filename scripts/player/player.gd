extends Spatial

var globals

func _ready():
	globals = get_tree().get_root().get_node("globals")
	
	globals.register_player(self)
