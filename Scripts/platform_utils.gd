extends Node

func is_web_build() -> bool:
	return OS.has_feature("web")
