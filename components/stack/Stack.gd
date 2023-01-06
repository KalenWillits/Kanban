extends VBoxContainer

var dindex: int

@onready 
var NotePackedScene: PackedScene = preload("res://components/note/Note.tscn")


func _on_button_button_down():
	var note = NotePackedScene.instantiate()
	note.dindex = get_child_count() - 1
	Cache.data[dindex].append("")
	add_child(note)
	note.text_box.grab_focus()

func is_empty():
	return get_child_count() > 1
	
	
func delete():
	Cache.data.remove_at(dindex)
	queue_free()
