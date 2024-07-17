@tool
class_name HTNTaskLine
extends HBoxContainer

@onready var edit_button: Button = %EditButton

func initialize(task_name: String) -> void:
	edit_button.text = task_name

func _on_delete_button_pressed() -> void:
	if HTNFileManager.delete_task(edit_button.text):
		HTNGlobals.warning_box.open(
			"You are about to delete this task for this graph and every graph that uses this.\nContinue?",
			func() -> void:
				HTNGlobals.task_deleted.emit()
				queue_free(),
			Callable()
		)
	else:
		HTNGlobals.notification_handler.send_error("Couldn't delete task: '" + edit_button.text + "'. Aborting...")

func _on_edit_button_pressed() -> void:
	HTNFileManager.edit_script(edit_button.text)
