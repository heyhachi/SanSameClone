class_name LicenseScreen
extends Control

func _ready() -> void:
	$CloseButton.pressed.connect(
		func() -> void:
			queue_free()
	)
	
	add_credit_text()
	
	%LicenseLabel.text += "\n--------------------------------------------------------------------------------\n
Puzzle Assets (1.1)

Created/distributed by Kenney (www.kenney.nl)

		------------------------------

License: (Creative Commons Zero, CC0)
http://creativecommons.org/publicdomain/zero/1.0/

This content is free to use in personal, educational and commercial projects.
Support us by crediting Kenney or www.kenney.nl (this is not mandatory)

		------------------------------

Donate:   http://support.kenney.nl
Patreon:  http://patreon.com/kenney/

Follow on Twitter for updates:
http://twitter.com/KenneyNL
\n--------------------------------------------------------------------------------\n"
	
	%LicenseLabel.text += "\n--------------------------------------------------------------------------------\n
	- SNES-Fighting06-14(Select).mp3
Copyright c 2012-2024 OtoLogic
https://otologic.jp/
\n--------------------------------------------------------------------------------\n"


func add_credit_text() -> void:
	%LicenseLabel.text += "\n----------------------------------------\n"
	var copyright_info := Engine.get_copyright_info()
	var license_info := Engine.get_license_info()
	
	for info: Dictionary in copyright_info:
		for part: Dictionary in info["parts"]:
			%LicenseLabel.text += "%s: %s, (C) %s\n"%[info["name"], part["license"], part["copyright"]]
			
	%LicenseLabel.text += "\n------------------------------------------------------------------------------------\n\n"
	
	for license_name: String in license_info:
		%LicenseLabel.text += "%s: \n%s\n"%[license_name, license_info[license_name]]
		%LicenseLabel.text += "------------------------------------------------------------------------------------\n"
