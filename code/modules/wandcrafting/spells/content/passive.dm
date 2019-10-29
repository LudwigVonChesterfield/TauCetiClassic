/obj/item/spell/passive
	category = "Passive"

	additional_delay = 0.0
	mana_cost = 0.0

	stackable = TRUE

	has_passive = TRUE
	passive_cast_delay = 0.0

/obj/item/spell/passive/examine(mob/user)
	..()
	if(passive_cast_delay != 0.0)
		to_chat(user, "<span class='info'>Would [passive_cast_delay > 0.0 ? "<span class='warning'>add <b>[abs(passive_cast_delay / 10.0)]</b></span>" : "remove <b>[abs(passive_cast_delay / 10.0)]</b>"] seconds of passive spell-cast delay.</span>")

/obj/item/spell/passive/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()
	if(passive_cast_delay != 0.0)
		dat = "Would [passive_cast_delay > 0.0 ? "<font color='red'>add <b>[passive_cast_delay * 0.1]</b></font>" : "remove <b>[-passive_cast_delay * 0.1]</b>"] seconds of passive spell-cast delay."
	return dat



/obj/item/spell/passive/forcefield
	name = "passive impenetrable barrier spell"
	desc = "This spell passively allows passage to none. Not even you."

	spell_icon = 'icons/effects/effects.dmi'
	spell_icon_state = "m_shield"

/obj/item/spell/passive/forcefield/on_passive_cast(obj/item/weapon/wand/holder, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/to_live = max((holder.spell_cast_delay * cur_mod.mult_power) + cur_mod.add_power, 2.0 SECONDS)
	new /obj/effect/forcefield/del_after(get_step(holder.loc, holder.loc.dir), to_live)



/obj/item/spell/passive/timestop
	name = "passive stop time spell"
	desc = "This spell freezes time around you, passively."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "time"

	mana_cost = 2.0

/obj/item/spell/passive/timestop/on_passive_cast(obj/item/weapon/wand/holder, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/to_live = max((holder.spell_cast_delay * cur_mod.mult_power) + cur_mod.add_power, 2.0 SECONDS)
	new /obj/effect/timestop(get_turf(holder), holder.loc, to_live)



/obj/item/spell/passive/mimefield
	name = "passive invisible barrier spell"
	desc = "This spell passively creates a somewhat invisible barrier."

	spell_icon = 'icons/effects/effects.dmi'
	spell_icon_state = "empty"

/obj/item/spell/passive/mimefield/on_passive_cast(obj/item/weapon/wand/holder, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/to_live = max((holder.spell_cast_delay * cur_mod.mult_power) + cur_mod.add_power, 2.0 SECONDS)
	new /obj/effect/forcefield/magic/mime(get_step(holder.loc, holder.loc.dir), holder.loc, to_live)
