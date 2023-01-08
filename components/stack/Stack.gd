extends VBoxContainer

var dindex: int

@onready 
var NotePackedScene: PackedScene = preload("res://components/note/Note.tscn")


func get_data():
	var data: Array[String]
	for i in range(1, get_child_count()):
		var note = get_child(i)
		data.append(note.text_box.get_text())
	return data
	
func make_new_note(content=""):
	var note = NotePackedScene.instantiate()
	note.dindex = get_child_count() - 1
	add_child(note)
	note.text_box.grab_focus()
	note.text_box.set_text(content)

func _on_button_button_down():
	make_new_note()


func is_empty():
	return get_child_count() <= 2
	
	
func delete():
	for i in range(dindex + 1, get_parent().get_child_count() - 1):
		var stack = get_parent().get_child(i)
		stack.dindex -= 1
	queue_free()
