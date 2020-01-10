/obj/item/spell/continuous
	name = "continuous cast spell"
	desc = "This \"spell\" allows to cast another spell, continuously."

	spell_components_slots = 1

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "show"

	mana_cost = 1
	additional_delay = 0

	var/next_delay = 1

	var/can_move = TRUE
	var/need_hand = TRUE

	var/datum/spell_modifier/copy_cur_mod

/obj/item/spell/continuous/examine(mob/user)
	..()
	if(spell_components.len > 0)
		to_chat(user, "~~~~~\n<span class='info'>Casts spell[spell_components.len == 1 ? "" : "s"]:</span>\n~~~~~")
		for(var/obj/item/spell/S in spell_components)
			S.examine(user)

/obj/item/spell/continuous/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()
	if(spell_components.len > 0)
		dat += "<i>Casts spell[spell_components.len == 1 ? "" : "s"]:</i><BR>~~~~~<BR>"
		for(var/obj/item/spell/S in spell_components)
			dat += "<a href='?src=\ref[SB];spell=[S.name];action=switch_to'>[S.name]</a>.<BR>"
		dat += "~~~~~<BR>"
		return dat

/obj/item/spell/continuous/proc/continuous_handler(obj/item/weapon/wand/holder, atom/casting_obj, atom/target)
	if(QDELING(holder) || QDELING(casting_obj) || QDELING(target))
		return

	if(spell_components.len == 0)
		return

	var/mob/caster = get_caster(casting_obj)
	if(!caster)
		return

	if(holder.interupt_continuous)
		return

	if(!spell_can_cast(holder, casting_obj, list(target), copy_cur_mod, copy_cur_mod))
		return

	var/spell_delay = 0
	if(do_after(caster, next_delay, target = holder, needhand = need_hand, can_move = can_move, progress = FALSE))
		for(var/obj/item/spell/S in spell_components)
			if(!S.spell_can_cast(holder, casting_obj, list(target), copy_cur_mod, copy_cur_mod))
				return
			spell_delay += affect(S, holder, casting_obj, target)
		next_delay = spell_delay + (additional_delay * copy_cur_mod.mult_delay) + copy_cur_mod.add_delay + holder.spell_cast_delay
		if(copy_cur_mod.boomerang)
			target = casting_obj
		INVOKE_ASYNC(src, .proc/continuous_handler, holder, casting_obj, target)

/obj/item/spell/continuous/proc/affect(obj/item/spell/S,obj/item/weapon/wand/holder, atom/casting_obj, atom/target)
	S.spell_otherscast(holder, casting_obj, target, copy_cur_mod, copy_cur_mod)
	return S.additional_delay * copy_cur_mod.mult_delay + copy_cur_mod.add_delay

/obj/item/spell/continuous/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	copy_cur_mod = cur_mod.get_copy()
	continuous_handler(holder, casting_obj, target)

/obj/item/spell/continuous/add_spell_component(obj/item/spell/S)
	return

/obj/item/spell/continuous/on_pre_remove(mob/user, obj/item/I)
	if(istype(I, /obj/item/spell))
		spell_components -= I
		if(istype(loc, /obj/item/weapon/wand))
			var/obj/item/weapon/wand/W = loc
			W.needs_reload = TRUE

/obj/item/spell/continuous/handle_modification(obj/item/I, mob/user)
	if(istype(I, /obj/item/spell))
		if(spell_components.len >= spell_components_slots)
			to_chat(user, "<span class='notice'>[src] can not contain any more spells.</span>")
			return FALSE

		user.remove_from_mob(I)
		user.update_icons()
		I.forceMove(src)

		spell_components += I
		if(istype(loc, /obj/item/weapon/wand))
			var/obj/item/weapon/wand/W = loc
			W.needs_reload = TRUE

		if(usr.client && usr.s_active != src)
			usr.client.screen -= I
		I.dropped(usr)
		add_fingerprint(usr)

		storage_ui.prepare_ui()
		storage_ui.on_insertion(user)

		return TRUE
	return FALSE



/obj/item/spell/continuous/muh_lazur
	spawn_with_component_types =  list(/obj/item/spell/projectile/muh_lazur)
	can_be_crafted = FALSE

/obj/item/spell/continuous/arcane_barrage
	spawn_with_component_types =  list(/obj/item/spell/projectile/arcane_barrage)
	can_be_crafted = FALSE

/obj/item/spell/continuous/earthquake
	spawn_with_component_types =  list(/obj/item/spell/earthquake)
	can_be_crafted = FALSE

/obj/item/spell/continuous/healing_beam
	spawn_with_component_types = list(/obj/item/spell/projectile/healing_beam)
	can_be_crafted = FALSE

/obj/item/spell/continuous/life_steal_beam
	spawn_with_component_types = list(/obj/item/spell/projectile/life_steal_beam)
	can_be_crafted = FALSE
