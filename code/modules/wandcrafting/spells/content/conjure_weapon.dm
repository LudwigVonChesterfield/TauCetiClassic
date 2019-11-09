/obj/item/spell/conjure/weapon
	time_to_live = 10 SECONDS
	var/apply_filter = TRUE

/obj/item/spell/conjure/weapon/spell_can_cast(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, spend_mana=TRUE)
	. = ..()
	if(. && ismob(casting_obj))
		var/mob/M = casting_obj
		return !M.get_inactive_hand()

/obj/item/spell/conjure/weapon/get_amount(def_am, mult_am, add_am)
	return 1

/obj/item/spell/conjure/weapon/modify_entity(obj/item/weapon/ent, obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	ent.name = "astral [ent.name]"
	ent.desc = "[ent.desc]. It's from another plane of existance!"

	if(apply_filter)
		ent.color = list(
			0.25, 0.0,  0.0, 0.0,
			0.0,  0.25, 0.0, 0.0,
			0.0,  0.0,  1.0, 0.0,
			0.0,  0.0,  0.0, 1.0,
			0.0,  0.0,  0.5, 0.0,
		)
		ent.alpha = 100

	ent.force = ent.force * cur_mod.mult_power + cur_mod.add_power
	// These are ghastly. Of course they care not of your pesky shields.
	ent.flags |= ABSTRACT|NODECONSTRUCT|NOSHIELD

	ent.setup_destructability()

	if(ismob(casting_obj))
		var/mob/M = casting_obj
		M.put_in_inactive_hand(ent)

	..()



/obj/item/weapon/blade
	name = "blade"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "sord"
	item_state = "sord"
	icon = 'icons/obj/weapons.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 16
	throwforce = 10
	sharp = TRUE
	edge = TRUE
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/spell/conjure/weapon/blade
	name = "conjure blade spell"
	desc = "This spell conjures a blade for you to fight with."

	spell_icon = 'icons/obj/weapons.dmi'
	spell_icon_state = "sord"

	to_spawn = list(/obj/item/weapon/blade = 1)

	mana_cost = 20
	additional_delay = 1

	apply_filter = TRUE



/obj/item/spell/conjure/weapon/shield
	name = "conjure shield spell"
	desc = "This spell conjures a shield for you to fight with."

	spell_icon = 'icons/obj/weapons.dmi'
	spell_icon_state = "buckler"

	to_spawn = list(/obj/item/weapon/shield/riot/roman = 1)

	mana_cost = 15
	additional_delay = 1

	apply_filter = TRUE



/obj/item/spell/conjure/weapon/spear
	name = "conjure spear spell"
	desc = "This spell conjures a spear for you to fight with."

	spell_icon = 'icons/obj/makeshift.dmi'
	spell_icon_state = "spearglass0"

	to_spawn = list(/obj/item/weapon/twohanded/spear = 1)

	mana_cost = 30
	additional_delay = 2

	apply_filter = TRUE
