extends VBoxContainer

const MAX_STACKS: int = 12
const MARGIN = 8
@onready var new_button = get_node("HBox/Div/VBox/HBox/Menu/NewButton")
@onready var StackPackedScene: PackedScene = preload("res://components/stack/Stack.tscn")

var null_has_focus = true


func get_user_dir():
	var path_array = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).split("/", false)
	var result: String = ""
	for i in range(0, path_array.size() - 1):
		result += "/%s" % path_array[i]
	result += "/"
	return result
	



func _ready():
	var env_savefile = OS.get_environment("KANBAN_SAVEFILE")
	$HBox/Div/VBox/HBox/Menu/Null.grab_focus()
	null_has_focus = true
	if env_savefile:
		Cache.savefile = env_savefile
		
	elif FileAccess.file_exists("user://config"):
		var file = FileAccess.open("user://config", FileAccess.READ)
		Cache.savefile = file.get_as_text()
	$HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.set_text(Cache.savefile)
	set_data(load_data())


func get_data():
	var data: Dictionary = {
		"data": [],
		"syntax": Cache.syntax
		}
	for i in range(1, $HBox/Div/VBox/HBox.get_child_count()):
		data.data.append($HBox/Div/VBox/HBox.get_child(i).get_data())
	return data
	
func set_data(data):
	if data != null:
		for stack_array in data.get("data", []):
			if stack_array.size() > 0:
				var stack = make_new_stack(stack_array[0])
				for i in range(1, stack_array.size()):
					stack.make_new_note(stack_array[i])
			else:
				var _stack = make_new_stack("")
		if data.get("syntax"):
			push_syntax(data.syntax)

func _input(_event):
	if Input.is_action_just_pressed("open"):
		_on_open_button_button_down()
	if Input.is_action_just_pressed("save"):
		_on_save_button_button_down()
	if Input.is_action_just_pressed("new"):
		_on_new_button_button_down()
	if Input.is_action_just_pressed("note"):
		_on_note_button_button_down()
	if Input.is_action_just_pressed("up"):
		_on_up_button_button_down()
	if Input.is_action_just_pressed("left"):
		_on_left_button_button_down()
	if Input.is_action_just_pressed("right"):
		_on_right_button_button_down()
	if Input.is_action_just_pressed("down"):
		_on_down_button_button_down()
	if Input.is_action_just_pressed("select"):
		_on_select_button_button_down()
	if Input.is_action_just_pressed("delete"):
		_on_delete_button_button_down()
	if Input.is_action_just_pressed("syntax"):
		_on_syntax_button_button_down()
	if Input.is_action_just_pressed("ui_cancel"):
		$HBox/Div/VBox/HBox/Menu/Null.grab_focus()
		
		
		
func make_new_stack(title: String):
	if ($HBox/Div/VBox/HBox.get_child_count() - 1) < MAX_STACKS:
		var stack = StackPackedScene.instantiate()
		stack.set_title(title)
		stack.dindex = $HBox/Div/VBox/HBox.get_child_count() - 1
		$HBox/Div/VBox/HBox.add_child(stack)
		$HBox/Div/VBox/HBox/Menu/Null.focus_next = $HBox/Div/VBox/HBox.get_child(1).get_node("TitleInput").get_path()
		return stack
	

func _on_new_button_button_down():
	make_new_stack("")


func _on_delete_button_button_down():
	if Cache.selected != null:
		Cache.selected.delete()


func _on_up_button_button_down():
	if Cache.selected != null:
		Cache.selected.decrement_position()


func _on_down_button_button_down():
	if Cache.selected != null:
		Cache.selected.increment_position()


func _on_right_button_button_down():
	if Cache.selected != null:
		Cache.selected.move_right()


func _on_left_button_button_down():
	if Cache.selected != null:
		Cache.selected.move_left()


func _on_focus_next_button_button_down():
	if Cache.selected != null:
		Cache.selected.next_focus()


func _on_open_button_button_down():
	$HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.show()
	$HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.grab_focus()

func _on_save_button_button_down():
	save_data(JSON.stringify(get_data(), "  "))
	
func reset():
	for i in range(1, $HBox/Div/VBox/HBox.get_child_count()):
		$HBox/Div/VBox/HBox.get_child(i).delete()

func save_data(content):
	var path = get_user_dir() + Cache.savefile
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)

func load_data():
	var file = FileAccess.open(get_user_dir() + Cache.savefile, FileAccess.READ)
	var content = ""
	if file:
		content = JSON.parse_string(file.get_as_text())
		return content
	return {"data": [], "syntax": ""}

func _on_tree_exiting():
	var file = FileAccess.open("user://config", FileAccess.WRITE)
	file.store_string(Cache.savefile)


func _on_open_file_input_text_submitted(new_text):
	reset()
	Cache.savefile = new_text
	set_data(load_data())
	$HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.hide()


func _on_open_file_input_focus_exited():
	$HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.hide()


func _on_select_button_button_down():
	if Cache.selected != null:
		var next = Cache.selected.get_next()
		if next != null:
			next.text_box.grab_focus()


func _on_note_button_button_down():
	if Cache.selected != null:
		match Cache.selected.type:
			"NOTE":
				Cache.selected.get_parent().make_new_note()
			"STACK":
				Cache.selected.make_new_note()
	elif $HBox/Div/VBox/HBox.get_child_count() > 1:
		$HBox/Div/VBox/HBox.get_child(1).make_new_note()


func _on_resized():
	DisplayServer.window_set_size(size)
	get_viewport().set_size(size)


func _on_syntax_button_button_down():
	$HBox/Div/VBox/HBox/Menu/SyntaxButton/SyntaxInput.show()
	$HBox/Div/VBox/HBox/Menu/SyntaxButton/SyntaxInput.grab_focus()

func push_syntax(syntax_string):
	$HBox/Div/VBox/HBox/Menu/SyntaxButton/SyntaxInput.text = syntax_string
	Cache.syntax = syntax_string
	var syntax = {}
	for syntax_arr in syntax_string.split(";"):
		var pair = syntax_arr.split(":")
		if pair.size() == 2:
			syntax[pair[0].strip_edges(true, true)] = pair[1].strip_edges(true, true)
	propagate_call("set_syntax", [syntax], false)

func _on_syntax_input_text_submitted(new_text):
	var keywords = {}
	push_syntax(new_text)
	$HBox/Div/VBox/HBox/Menu/SyntaxButton/SyntaxInput.hide()


func _on_syntax_input_focus_exited():
	$HBox/Div/VBox/HBox/Menu/SyntaxButton/SyntaxInput.hide()


func _on_null_focus_entered():
	if $HBox/Div/VBox/HBox.get_child_count() > 1 and null_has_focus:
		$HBox/Div/VBox/HBox.get_child(1).get_node("TitleInput").grab_focus()


func _on_null_focus_exited():
	null_has_focus = false
