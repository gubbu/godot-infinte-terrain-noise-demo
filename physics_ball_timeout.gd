extends RigidBody


func _on_Timer_timeout():
	self.queue_free()
