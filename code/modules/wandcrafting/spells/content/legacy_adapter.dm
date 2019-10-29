/obj/item/spell/legacy
	category = "Ancient"

	var/legacy_spell_type = /obj/effect/proc_holder/spell
	var/obj/effect/proc_holder/spell/my_legacy_spell

	// Whether the spell should be recharged after casting automatically.
	var/recharge_after_cast = TRUE

/obj/item/spell/legacy/atom_init()
	. = ..()
	my_legacy_spell = new legacy_spell_type(src)

/obj/item/spell/legacy/examine(mob/living/user)
	..()
	to_chat(user, "<span class='warning'>It seems such ancient, arcane magic is not affected by cast modifiers...</span>")
	to_chat(user, "<span class='warning'>It seems such forgotten legacy does not play by the rules of triggers and timers...</span>")

/obj/item/spell/legacy/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()
	dat += "<i>It seems such ancient, arcane magic is not affected by cast modifiers...</i><BR>"
	dat += "<i>It seems such forgotten legacy does not play by the rules of triggers and timers...</i><BR>"
	return dat

/obj/item/spell/legacy/spell_can_cast(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, spend_mana=TRUE)
	. = ..()
	if(. && ismob(casting_obj))
		return my_legacy_spell.cast_check(skipcharge = FALSE, user = casting_obj)

/obj/item/spell/legacy/spell_otherscast(obj/item/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(istype(my_legacy_spell, /obj/effect/proc_holder/spell/targeted) || istype(my_legacy_spell, /obj/effect/proc_holder/spell/aoe_turf) || istype(my_legacy_spell, /obj/effect/proc_holder/spell/dumbfire))
		my_legacy_spell.choose_targets(casting_obj)
	else
		my_legacy_spell.perform(list(target), recharge_after_cast)

/obj/item/spell/legacy/spell_areacast(obj/item/wand/holder, mob/living/user, list/turfs, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(istype(my_legacy_spell, /obj/effect/proc_holder/spell/targeted) || istype(my_legacy_spell, /obj/effect/proc_holder/spell/aoe_turf) || istype(my_legacy_spell, /obj/effect/proc_holder/spell/dumbfire))
		my_legacy_spell.choose_targets()
	else
		my_legacy_spell.perform(turfs, recharge_after_cast)



/obj/item/spell/legacy/magic_missile
	name = "magic missile spell"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	spell_icon = 'icons/obj/projectiles.dmi'
	spell_icon_state = "magicm"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	recharge_after_cast = TRUE

	mana_cost = 10



/obj/item/spell/legacy/lightning_shock
	name = "lighting shock spell"
	desc = "Hold your target with electricity for 5 seconds. Disarms target making drop all in hands and impossibility pick up it again."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "summons"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/lighting_shock
	recharge_after_cast = TRUE

	mana_cost = 15



/obj/item/spell/legacy/repulse
	name = "repulse spell"
	desc = "This spell throws everything around the user away."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "repulse"

	legacy_spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	recharge_after_cast = TRUE

	mana_cost = 5



/obj/item/spell/legacy/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "barn"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	recharge_after_cast = TRUE

	mana_cost = 20
	additional_delay = 1



/obj/item/spell/legacy/para_smoke
	name = "paralysing smoke spell"
	desc = "This spell spawns a cloud of paralysing smoke."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "smoke"

	legacy_spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/smoke
	recharge_after_cast = TRUE

	mana_cost = 30
	additional_delay = 2



/obj/item/spell/legacy/genetic
	name = "gene-shift spell"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "statue"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/genetic/random
	recharge_after_cast = TRUE

	mana_cost = 20
	additional_delay = 1



/obj/item/spell/legacy/emplosion
	name = "area emplosion spell"
	desc = "This spell emplodes an area."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "emp"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/emplosion
	recharge_after_cast = TRUE

	mana_cost = 50
	additional_delay = 2



/obj/item/spell/legacy/gnomecurse
	name = "Gift of the Gnome"
	desc = "This spell grands any person around you a great gift of being a Gnome."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "gnomed"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/gnomecurse
	recharge_after_cast = TRUE

	mana_cost = 30
	additional_delay = 2



/obj/item/spell/legacy/smoke
	name = "ancient smoke spell"
	desc = "This spell summons smoke at thy position."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "smoke"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	recharge_after_cast = TRUE

	mana_cost = 10
	additional_delay = 4



/obj/item/spell/legacy/blink
	name = "ancient blink spell"
	desc = "This spell randomly teleports you a short distance."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "blink"

	legacy_spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	recharge_after_cast = TRUE

	mana_cost = 5
	additional_delay = 0
