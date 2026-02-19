extends Node
class_name Goal


signal completed

var isCompleted:= false


func complete():
	if isCompleted:
		return
	isCompleted = true
	completed.emit()
