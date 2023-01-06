extends ScrollContainer

@onready
var StackPackedScene: PackedScene = preload("res://components/stack/Stack.tscn")

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		$VBox/HBox/Div/VBox/HBox/Menu/NewButton.grab_focus()

func _on_new_button_button_down():
	var stack = StackPackedScene.instantiate()
	stack.dindex = $VBox/HBox/Div/VBox/HBox.get_child_count() - 1
	Cache.data.append([])
	$VBox/HBox/Div/VBox/HBox.add_child(stack)


func _on_delete_button_button_down():
	if Cache.selected != null:
		if Cache.selected.get_parent().is_empty():
			Cache.selected.get_parent().delete()
		else:
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
