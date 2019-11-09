/obj/item/spell/conjure/mime
	time_to_live = 10 SECONDS
	var/apply_filter = TRUE

/obj/item/spell/conjure/mime/get_amount(def_am, mult_am, add_am)
	return def_am

/obj/item/spell/conjure/mime/modify_entity(atom/ent, obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	ent.name = "invisible [ent.name]"
	ent.desc = "[ent.desc]. It's invisible!"

	ent.flags |= ABSTRACT|NODECONSTRUCT

	if(apply_filter)
		ent.color = TO_GREYSCALE_COLOR
		ent.alpha = 100

	ent.spawn_destruction_reagents = null
	ent.setup_destructability()

	..()



/obj/item/spell/conjure/mime/wall
	name = "mimetic wall spell"
	desc = "This spell conjures a somewhat invisible wall."

	spell_icon = 'icons/effects/effects.dmi'
	spell_icon_state = "empty"

	// to_spawn = list(/obj/effect/forcefield/magic/mime = 1)

	mana_cost = 15
	additional_delay = 0

	apply_filter = FALSE

/obj/item/spell/conjure/mime/wall/conjure_entities(atom/conj_loc, atom/casting_obj, mult_am, add_am)
	. = list()
	var/am = get_amount(1, mult_am, add_am)
	if(am > 0)
		for(var/i in 1 to am)
			. += new /obj/effect/forcefield/magic/mime(conj_loc, casting_obj, -1)

/obj/item/spell/conjure/mime/wall/modify_entity(atom/ent, obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	return


/obj/item/spell/conjure/mime/chair
	name = "mimetic chair spell"
	desc = "This spell conjures a somewhat invisible chair."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "mime"

	// to_spawn = list(/obj/structure/stool/bed/chair/metal/white = 1)

	mana_cost = 15
	additional_delay = 4

/obj/item/spell/conjure/mime/chair/get_to_spawn()
	return pick(
		list(/obj/structure/stool/bed/chair/metal/white = 1),
		list(/obj/structure/stool/bed/chair/wood/normal = 1),
		list(/obj/structure/stool/bed/chair/comfy/beige = 1),
		list(/obj/structure/stool/bed/chair/office/light = 1),
		)



/obj/structure/stool/bed/chair/janitorialcart/mime/Destroy()
	spill(200)
	return ..()

/obj/item/spell/conjure/mime/janicart
	name = "mimetic janitorial cart spell"
	desc = "This spell conjures a somewhat invisible janitorial cart, wait, what?."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "mime"

	to_spawn = list(/obj/structure/stool/bed/chair/janitorialcart/mime = 1)

	mana_cost = 15
	additional_delay = 4


/obj/structure/closet/mime
	// An assoc list of form closed = opened.
	var/static/list/pos_states = list(
		"closet" = "open",
		"blue" = "open",
		"mixe" = "open",
		"atmos" = "open",
		"blue" = "open",
		"bio" = "bioopen",
		"emergency" = "emergencyopen",
		"secure" = "secureopen",
		"secure1" = "secureopen",
		"chemical" = "medicalopen",
		"chemical1" = "medicalopen",
		"firecloset" = "fireclosetopen",
		"toolcloset" = "toolclosetopen",
		"radsuitcloset" = "toolclosetopen",
		"miningsec" = "miningsecopen",
		"miningsec1" = "miningsecopen",
		"bombsuit" = "bombsuitopen",
		"cabinet_closed" = "cabinet_open",
		"cabinetdetective" = "cabinetdetective_open",
		"abductor" = "abductoropen",
		"critter" = "critteropen",
		"coffin" = "coffin_open",
		)

/obj/structure/closet/mime/atom_init()
	. = ..()
	var/new_ic_st = pick(pos_states)
	icon_state = new_ic_st
	icon_opened = pos_states[new_ic_st]
	icon_closed = new_ic_st

/obj/structure/closet/mime/Destroy()
	dump_contents()

	return ..()

/obj/item/spell/conjure/mime/closet
	name = "mimetic closet spell"
	desc = "This spell conjures a somewhat invisible closet."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "mime"

	to_spawn = list(/obj/structure/closet/mime = 1)

	mana_cost = 15
	additional_delay = 4
