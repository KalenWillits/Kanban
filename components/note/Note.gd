extends VBoxContainer

const type = "NOTE"
@export var TextBoxNodePath: NodePath
@onready var text_box = get_node(TextBoxNodePath)
var dindex
var font: Font

signal on_select(note)

func _ready():
	font = $VBox/HBox/TextBox.get("theme_override_fonts/font")

func _on_text_focus_entered():
	Cache.selected = self
	
	
func increment_position():
	if (get_parent().get_child_count() - 1) > dindex + 1:
		get_parent().move_child(self, dindex + 2)
		dindex += 1
		text_box.grab_focus()
	
func decrement_position():
	if 0 < dindex:
		get_parent().move_child(self, dindex)
		dindex -= 1
		text_box.grab_focus()
		
func move_right():
	if get_parent().dindex < (get_parent().get_parent().get_child_count() - 2):
		dindex = get_parent().get_parent().get_child(get_parent().dindex + 2).get_child_count() - 2
		var copy = duplicate()
		copy.dindex = dindex
		get_parent().get_parent().get_child(get_parent().dindex + 2).add_child(copy)
		queue_free()
		copy.text_box.grab_focus()


func move_left():
	if get_parent().dindex > 0:
		dindex = get_parent().get_parent().get_child(get_parent().dindex).get_child_count() - 2
		var copy = duplicate()
		copy.dindex = dindex
		get_parent().get_parent().get_child(get_parent().dindex).add_child(copy)
		queue_free()
		copy.text_box.grab_focus()

func get_next():
	if get_parent().get_parent().get_child_count() > 1:
		if (get_parent().get_child_count() - 1) > dindex + 1:
			return get_parent().get_child(dindex + 2)
		elif get_parent().dindex < (get_parent().get_parent().get_child_count() - 1):
			if get_parent().get_parent().get_child_count() > 1:
				if get_parent().get_parent().get_child(get_parent().dindex + 2) != null:
					if get_parent().get_parent().get_child(get_parent().dindex + 2).get_child_count() > 1:
						return get_parent().get_parent().get_child(get_parent().dindex + 2).get_child(1)
					else:
						return get_parent().get_parent().get_child(1).get_child(1)
				else:
					return get_parent().get_parent().get_child(1).get_child(1)
			else:
				return get_parent().get_parent().get_child(1).get_child(1)
		else:
			return get_parent().get_parent().get_child(1).get_child(1)
			
func set_syntax(syntax: Dictionary):
	var highlighter = CodeHighlighter.new()
	highlighter.set_keyword_colors(syntax)
	text_box.syntax_highlighter = highlighter

func delete():
	queue_free()
