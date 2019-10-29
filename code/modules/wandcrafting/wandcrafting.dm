/obj/item/weapon/wand/proc/add_wand_component(obj/item/wand_component/WC)
	WC.forceMove(src)

/obj/item/weapon/wand/proc/remove_wand_component(obj/item/wand_component/WC)
	var/atom/move_to = loc
	if(ismob(move_to))
		var/mob/M = move_to
		move_to = M.loc
	WC.forceMove(move_to)

/obj/item/weapon/wand/proc/add_spell(obj/item/spell/S)
	S.forceMove(src)

/obj/item/weapon/wand/proc/remove_spell(obj/item/spell/S)
	var/atom/move_to = loc
	if(ismob(move_to))
		var/mob/M = move_to
		move_to = M.loc
	S.forceMove(move_to)

/obj/item/weapon/wand/proc/open(mob/user)
	storage_ui.prepare_ui()
	storage_ui.on_open(user)
	storage_ui.show_to(user)

/obj/item/weapon/wand/proc/close(mob/user)
	close_all()

/obj/item/weapon/wand/proc/close_all()
	wand_components_storage.close_all()
	spells_storage.close_all()

/obj/item/weapon/wand/proc/show_to(mob/user)
	storage_ui.show_to(user)

/obj/item/weapon/wand/proc/hide_from(mob/user)
	storage_ui.hide_from(user)

/obj/item/weapon/wand/proc/can_be_inserted()
	return FALSE

// Returns TRUE if it was a spell or wand component, and it got inserted.
/obj/item/weapon/wand/proc/handle_modification(obj/item/W, mob/user)
	var/datum/storage_ui/to_update
	if(istype(W, /obj/item/spell))
		if(spells.len >= spells_slots)
			to_chat(user, "<span class='notice'>[src] can not contain any more spells.</span>")
			return FALSE
		to_update = spells_storage
	else if(istype(W, /obj/item/wand_component))
		var/obj/item/wand_component/WC = W
		if(wand_components.len >= wand_components_slots)
			to_chat(user, "<span class='notice'>[src] can not contain any more components.</span>")
			return FALSE
		for(var/list/incomp_list in wand_component_incompatible_flags)
			for(var/wand_flag in wand_component_flags)
				for(var/comp_flag in WC.add_flags)
					if((wand_flag in incomp_list) && (comp_flag in incomp_list) && wand_flag != comp_flag)
						to_chat(user, "<span class='notice'><b>[WC]</b> is incompatible with <b>[src]</b>, because of <b>[comp_flag]</b> not being compatible with <b>[wand_flag]</b>.</span>")
						return FALSE
		to_update = wand_components_storage

	if(!to_update)
		return FALSE

	user.remove_from_mob(W)
	user.update_icons()
	W.forceMove(src)

	if(usr.client && usr.s_active != src)
		usr.client.screen -= W
	W.dropped(usr)
	add_fingerprint(usr)

	to_update.prepare_ui()
	to_update.on_insertion(user)

	return TRUE

/obj/item/weapon/wand/attackby(obj/item/W, mob/user)
	if(handle_modification(W, user))
		return
	return ..()

/obj/item/weapon/wand/attack_hand(mob/living/user)
	if(user.a_intent != I_HURT && user.get_inactive_hand() == src)
		open(user)
		return
	return ..()

/obj/item/weapon/wand/MouseDrop(atom/movable/over_object)
	if(!ishuman(usr) && !ismonkey(usr) && !isIAN(usr))
		return

	if(!over_object)
		return

	if(over_object == usr && Adjacent(usr))
		open(usr)
		return

	if(!istype(over_object, /obj/screen))
		return ..()

	//makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
	//there's got to be a better way of doing this.
	if(!(loc == usr) || (loc && loc.loc == usr))
		return

	if(!usr.restrained() && !usr.stat)
		switch(over_object.name)
			if("r_hand")
				if(!usr.unEquip(src))
					return
				usr.put_in_r_hand(src)
			if("l_hand")
				if(!usr.unEquip(src))
					return
				usr.put_in_l_hand(src)
			if("mouth")
				if(!usr.unEquip(src))
					return
				usr.put_in_active_hand(src)
		add_fingerprint(usr)

/obj/item/weapon/wand/verb/toggle_spells_components()
	set name = "Toggle spells/components setup"
	set desc = "Toggles between setting up spells or components of the wand."
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	close_all()

	if(storage_ui == spells_storage)
		storage_ui = wand_components_storage
	else
		storage_ui = spells_storage
	open(usr)
	to_chat(usr, "<span class='notice'>You are now configuring [src]'s [storage_ui == spells_storage ? "spells" : "components"]!")
