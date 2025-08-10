extends Node

var Generic1Stage = {
	"name": "Generic 1-Stage",
	"scene": "res://Scenes/FreeRoam/Generic/Generic1Stage.tscn",
	"stage": Stages.Cyber1Stage,
	"curtains": {
		"Curtain": [ "1-Stage" ]
	}
}

var Generic2Stage = {
	"name": "Generic 2-Stage",
	"scene": "res://Scenes/FreeRoam/Generic/Generic2Stage.tscn",
	"stage": Stages.Cyber2Stage,
	"curtains": {
		"Curtains": [ "CEC", "Main" ]
	}
}

var GenericMiniUnit1Stage = {
	"name": "Generic Mini Unit 1-Stage",
	"scene": "res://Scenes/FreeRoam/Generic/GenericMiniUnit1Stage.tscn",
	"stage": Stages.MiniUnit1Stage,
	"curtains": [ ]
}

var MapIndex = {
	"Generic 1-Stage": Generic1Stage,
	"Generic 2-Stage": Generic2Stage,
	"Generic Mini Unit 1-Stage": GenericMiniUnit1Stage,
}
