/obj/item/spell/modifier/bifuscated
	name = "bifuscation spell"
	desc = "This spell diverges the two cast spells in a bifuscated manner."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_yellow"

	add_casts = 1

/obj/item/spell/modifier/bifuscated/atom_init()
	. = ..()
	diverge_dirs = list()
	for(var/ang in list(90, -90))
		var/datum/diverge_dir/DD = new()
		DD.angle = ang
		diverge_dirs += DD



/obj/item/spell/modifier/trifuscated
	name = "trifuscation spell"
	desc = "This spell diverges the two additional spells in a trifuscated manner."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_yellow"

	add_casts = 2

/obj/item/spell/modifier/trifuscated/atom_init()
	. = ..()
	diverge_dirs = list()
	for(var/ang in list(0, 90, -90))
		var/datum/diverge_dir/DD = new()
		DD.angle = ang
		diverge_dirs += DD



/obj/item/spell/modifier/backcast
	name = "back-cast spell"
	desc = "This spell causes the second cast spell to be cast out of your... Back."

	spell_icon = 'icons/obj/bureaucracy.dmi'
	spell_icon_state = "folder_yellow"

	add_casts = 1

/obj/item/spell/modifier/backcast/atom_init()
	. = ..()
	additional_cast_dirs = list()
	for(var/ang in list(0, 180))
		var/datum/cast_dir/CD = new()
		CD.angle = ang
		additional_cast_dirs += CD
