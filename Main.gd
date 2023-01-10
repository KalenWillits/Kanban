extends ScrollContainer

const MAX_STACKS: int = 12
const MARGIN = 8
@onready var new_button = get_node("VBox/HBox/Div/VBox/HBox/Menu/NewButton")

@onready var StackPackedScene: PackedScene = preload("res://components/stack/Stack.tscn")

func get_user_dir():
	var path_array = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).split("/", false)
	var result: String = ""
	for i in range(0, path_array.size() - 1):
		result += "/%s" % path_array[i]
	result += "/"
	return result

func _ready():
	var env_savefile = OS.get_environment("KANBAN_SAVEFILE")

	if env_savefile:
		Cache.savefile = env_savefile
		
	elif FileAccess.file_exists("user://config"):
		var file = FileAccess.open("user://config", FileAccess.READ)
		Cache.savefile = file.get_as_text()
	$VBox/HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.set_text(Cache.savefile)
	set_data(load_data())


func get_data():
	var data: Array
	for i in range(1, $VBox/HBox/Div/VBox/HBox.get_child_count()):
		data.append($VBox/HBox/Div/VBox/HBox.get_child(i).get_data())
	return data
	
func set_data(data):
	if data != null:
		for stack_array in data:
			if stack_array.size() > 0:
				var stack = make_new_stack(stack_array[0])
				for i in range(1, stack_array.size()):
					stack.make_new_note(stack_array[i])
			else:
				var _stack = make_new_stack("")

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$VBox/HBox/Div/VBox/HBox/Menu/NewButton.grab_focus()
		
		
func make_new_stack(title: String):
	if ($VBox/HBox/Div/VBox/HBox.get_child_count() - 1) < MAX_STACKS:
		var stack = StackPackedScene.instantiate()
		stack.set_title(title)
		stack.dindex = $VBox/HBox/Div/VBox/HBox.get_child_count() - 1
		$VBox/HBox/Div/VBox/HBox.add_child(stack)
		return stack
	

func _on_new_button_button_down():
	make_new_stack("")


func _on_delete_button_button_down():
	if Cache.selected != null:
		match Cache.selected.type:
			"NOTE":
				if Cache.selected.get_parent().is_empty():
					Cache.selected.get_parent().delete()
				else:
					Cache.selected.delete()
			"STACK":
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
	$VBox/HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.show()
	$VBox/HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.grab_focus()

func _on_save_button_button_down():
	save_data(JSON.stringify(get_data(), "  "))
	
func reset():
	for i in range(1, $VBox/HBox/Div/VBox/HBox.get_child_count()):
		$VBox/HBox/Div/VBox/HBox.get_child(i).delete()

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
	return []

func _on_tree_exiting():
	var file = FileAccess.open("user://config", FileAccess.WRITE)
	file.store_string(Cache.savefile)


func _on_open_file_input_text_submitted(new_text):
	reset()
	Cache.savefile = new_text
	set_data(load_data())
	$VBox/HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.hide()


func _on_open_file_input_focus_exited():
	$VBox/HBox/Div/VBox/HBox/Menu/OpenButton/OpenFileInput.hide()


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
	elif $VBox/HBox/Div/VBox/HBox.get_child_count() > 1:
		$VBox/HBox/Div/VBox/HBox.get_child(1).make_new_note()
