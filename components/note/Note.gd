extends VBoxContainer

@export var TextBoxNodePath: NodePath
@onready var text_box = get_node(TextBoxNodePath)
var dindex

signal on_select(note)

func _ready():
	pass # Replace with function body

func _on_text_focus_entered():
	Cache.selected = self
	
	
func increment_position():
	print(Cache.data[get_parent().dindex].size() > dindex)
	if Cache.data[get_parent().dindex].size() > dindex + 1:
		print('MOV')
		get_parent().move_child(self, dindex + 2)
		Cache.data[get_parent().dindex].remove_at(dindex)
		dindex += 1
		Cache.data[get_parent().dindex].insert(dindex, text_box.get_text())
		text_box.grab_focus()
	
func decrement_position():
	if 0 < dindex:
		get_parent().move_child(self, dindex)
		Cache.data[get_parent().dindex].remove_at(dindex)
		dindex -= 1
		Cache.data[get_parent().dindex].insert(dindex, text_box.get_text())
		text_box.grab_focus()
		
func move_right():
	if get_parent().dindex < (Cache.data.size() - 1):
		Cache.data[get_parent().dindex].remove_at(dindex)
		dindex = get_parent().get_parent().get_child(get_parent().dindex + 2).get_child_count() - 2
		var copy = duplicate()
		copy.dindex = dindex
		get_parent().get_parent().get_child(get_parent().dindex + 2).add_child(copy)
		Cache.data[get_parent().get_parent().get_child(get_parent().dindex + 2).dindex].append(text_box.get_text())
		queue_free()
		copy.text_box.grab_focus()


func move_left():
	if get_parent().dindex > 0:
		Cache.data[get_parent().dindex].remove_at(dindex)
		dindex = get_parent().get_parent().get_child(get_parent().dindex).get_child_count() - 2
		var copy = duplicate()
		copy.dindex = dindex
		get_parent().get_parent().get_child(get_parent().dindex).add_child(copy)
		Cache.data[get_parent().get_parent().get_child(get_parent().dindex).dindex].append(text_box.get_text())
		queue_free()
		copy.text_box.grab_focus()


func _on_text_box_text_changed():
	Cache.data[get_parent().dindex][dindex] = text_box.get_text()
	
func delete():
	Cache.data[get_parent().dindex].remove_at(dindex)
	queue_free()
