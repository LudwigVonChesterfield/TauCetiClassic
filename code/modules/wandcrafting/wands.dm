/obj/item/weapon/wand
	action_button_name = "Activate"

	// Never touch the block of these variables manually. At all.
	// <BLOCK>
	var/mana = 0 // see: get_mana(), adjust_mana(), use_mana()

	var/datum/progressbar/manabar

	var/list/spells_queue = list()
	var/needs_reload = TRUE

	var/wand_component_flags = list()

	var/list/wand_components = list()
	var/list/spells = list()
	// Spells that are cast in process()
	var/list/passive_spells
	// This spell is conjured once per cast, regardless of any checks.
	// If something was cast, this spell will be too.
	// Take care.
	var/obj/item/spell/always_casts

	var/next_spell_cast = 0

	var/datum/storage_ui/storage_ui

	var/datum/storage_ui/wands/wand_components_storage
	var/datum/storage_ui/wands/spells_storage

	var/list/enchanted_items = list()
	// </BLOCK>

	var/list/default_spells
	var/list/default_wand_components
	var/always_casts_spell_type

	var/spells_per_click = 1

	var/max_mana = 100
	var/passive_mana_charge = 0

	var/spells_slots = 4
	var/wand_components_slots = 4

	var/spell_cast_delay = 0
	var/spell_recharge_delay = 0
	var/spell_queue_type = WAND_QUEUE_ORDER

	var/default_color
	var/matrix/default_transform

	var/datum/spell_modifier/cur_mod
	var/datum/spell_modifier/next_mod

	var/interupt_continuous = FALSE

/obj/item/weapon/wand/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

	mana = max_mana

	cur_mod = get_default_cast_modifier()
	next_mod = get_default_cast_modifier()

	spells_storage = new(src, spells, spells_slots)
	wand_components_storage = new(src, wand_components, wand_components_slots)

	storage_ui = spells_storage

	for(var/spell_type in default_spells)
		var/obj/item/spell/S = new spell_type(null)
		add_spell(S)

	for(var/wand_component_type in default_wand_components)
		var/obj/item/wand_component/WC = new wand_component_type(null)
		add_wand_component(WC)

	if(always_casts_spell_type)
		always_casts = new always_casts_spell_type(null)

	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/wand/atom_init_late()
	default_color = color
	default_transform = transform

/obj/item/weapon/wand/Destroy()
	QDEL_NULL(manabar)

	spells_queue = null

	// deleting a spell handles removal from this array, as well as removal from passive_spells.
	QDEL_LIST(spells)
	QDEL_LIST(wand_components)

	QDEL_NULL(always_casts)

	for(var/obj/item/I in enchanted_items)
		I.enchantment_wand = null
		I.disenchant()
	enchanted_items = null

	storage_ui = null
	QDEL_NULL(wand_components_storage)
	QDEL_NULL(spells_storage)
	return ..()

/obj/item/weapon/wand/process()
	if(wand_component_flags[WAND_COMP_PASSIVECAST])
		var/next_cur_mod_cycle = FALSE


		for(var/obj/item/spell/S in passive_spells)
			var/delay = (spell_cast_delay + S.passive_cast_delay) * cur_mod.mult_delay + cur_mod.add_delay * 2
			if(S.last_cast + delay > world.time)
				continue

			if(S.spell_can_cast(src, loc, list(), cur_mod))
				INVOKE_ASYNC(S, /obj/item/spell.proc/passive_cast, src, cur_mod, next_mod)

			if(!S.stackable)
				next_cur_mod_cycle = TRUE

			if(always_casts)
				INVOKE_ASYNC(always_casts, /obj/item/spell.proc/passive_cast, src, cur_mod, next_mod)
				if(!always_casts.stackable)
					next_cur_mod_cycle = TRUE

		if(next_cur_mod_cycle)
			cur_mod = next_mod
			next_mod = get_default_cast_modifier()

	adjust_mana(passive_mana_charge)

/obj/item/weapon/wand/examine(mob/user)
	..()
	if(always_casts)
		to_chat(user, "~~~~~\n<span class='info'>Always casts:</info>\n~~~~~")
		always_casts.examine(user)
		to_chat(user, "\n")

	switch(spell_queue_type)
		if(WAND_QUEUE_ORDER)
			to_chat(user, "<span class='info'>This wand casts in an orderly manner.</span>")
		if(WAND_QUEUE_SHUFFLE)
			to_chat(user, "<span class='info'>This wand casts <span class='warning'>in a shuffled manner</span>.</span>")
		if(WAND_QUEUE_RANDOM)
			to_chat(user, "<span class='info'>This wand casts <span class='danger'>any built-in spell, at random</span>.</span>")

	to_chat(user, "<span class='info'>This wand conjures <b>[spells_per_click]</b> spell[abs(spells_per_click) == 1.0 ? "s" : ""] per cast.</span>")
	to_chat(user, "<span class='info'>This wand has <b>[spells_slots]</b> spell slot[spells_slots > 1.0 ? "s" : ""].</span>")
	to_chat(user, "<span class='info'>This wand has <b>[wand_components_slots]</b> wand component slot[wand_components_slots > 1.0 ? "s" : ""].</span>")

	to_chat(user, "<span class='info'>This wand has a maximum of <b>[max_mana]</b> mana stored.</span>")
	to_chat(user, "<span class='info'>This wand's mana restoration rate is <b>[passive_mana_charge > 0.0 ? passive_mana_charge : "<span class='warning'>[passive_mana_charge]</span>"]</b> per second.</span>")

	to_chat(user, "<span class='info'>The between-spells cast delay of this wand is <b>[spell_cast_delay * 0.1]</b> seconds.</span>")
	to_chat(user, "<span class='info'>The recharge time of this wand is <b>[spell_recharge_delay * 0.1]</b> seconds.</span>")

/obj/item/weapon/wand/attack_self(mob/user)
	try_reload(user)

/obj/item/weapon/wand/equipped(mob/user, slot)
	if((slot == SLOT_L_HAND) || (slot == SLOT_R_HAND))
		manabar = new /datum/progressbar(user, max_mana, src, my_icon_state="combat_prog_bar", insert_under=TRUE)
		manabar.update(get_mana())
	else
		QDEL_NULL(manabar)

/obj/item/weapon/wand/dropped(mob/user)
	QDEL_NULL(manabar)

/obj/item/weapon/wand/proc/display_spell_cooldown()
	color = TO_NEGATIVE_COLOR
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/weapon/wand/proc/display_spell_readiness()
	color = default_color
	// transform = default_transform
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/weapon/wand/proc/set_max_mana(value)
	max_mana = value
	QDEL_NULL(manabar)
	if(ismob(loc) && slot_equipped & SLOT_L_HAND|SLOT_R_HAND)
		var/mob/M = loc
		manabar = new /datum/progressbar(M, max_mana, src, my_icon_state="combat_prog_bar", insert_under=TRUE)
		manabar.update(get_mana())

/obj/item/weapon/wand/proc/get_mana()
	return mana

/obj/item/weapon/wand/proc/adjust_mana(value)
	var/cur_mana = get_mana()
	mana = CLAMP(cur_mana + value, 0, max_mana)
	if(mana != cur_mana && manabar)
		manabar.update(mana)

// Returns WAND_SUCCESS if mana usage was succesful, returns some "error code" otherwise.
/obj/item/weapon/wand/proc/use_mana(value)
	var/cur_mana = get_mana()
	if(cur_mana < value)
		return WAND_NOT_ENOUGH_MANA
	adjust_mana(-value)
	return WAND_SUCCESS

/obj/item/weapon/wand/proc/get_next_spells()
	var/am_to_cast = spells_per_click + cur_mod.add_casts
	if(am_to_cast <= 0.0)
		return list()

	if(spells_queue.len == 0)
		needs_reload = TRUE
		return list()

	// Prevents infinitely duping clone next spells.
	if(spells_queue.len > spells.len * 2)
		needs_reload = TRUE
		return list()

	var/list/retVal = list()
	for(var/i in 1 to am_to_cast)
		var/obj/item/spell/S = spells_queue[1]
		retVal += S
		spells_queue -= S

		if(spells_queue.len == 0)
			needs_reload = TRUE
			return retVal

	return retVal

/obj/item/weapon/wand/proc/set_spell_queue()
	switch(spell_queue_type)
		if(WAND_QUEUE_ORDER)
			spells_queue = list() + spells
		if(WAND_QUEUE_SHUFFLE)
			spells_queue = shuffle(spells)
		if(WAND_QUEUE_RANDOM)
			spells_queue = list()
			for(var/i in 1 to spells.len)
				spells_queue += pick(spells)

/obj/item/weapon/wand/proc/try_reload(mob/living/user)
	if(!istype(user))
		return

	if(next_spell_cast > world.time)
		to_chat(user, "<span class='warning'>[src] can not be reloaded so soon after last cast.</span>")
		return

	interupt_continuous = TRUE
	if(!user.is_busy(show_warning = FALSE))
		to_chat(user, "<span class='notice'>You begin reloading [src]!</span>")
		if(do_after(user, spell_recharge_delay, target = src, progress = TRUE, can_move = wand_components[WAND_COMP_RELOADMOVE]))
			set_spell_queue()
			needs_reload = FALSE
			interupt_continuous = FALSE

// Current cast_types are WAND_COMP_SELFCAST, WAND_COMP_OTHERSCAST, WAND_COMP_AREACAST
/obj/item/weapon/wand/proc/try_casting(cast_type, list/targets, atom/casting_obj)
	var/next_cur_mod_cycle = TRUE

	if(needs_reload)
		try_reload(casting_obj)
		return

	if(spells.len == 0)
		if(ismob(casting_obj))
			to_chat(casting_obj, "<span class='warning'>It seems [src] has no spells!</span>")
		return

	var/list/to_cast = get_next_spells()
	if(islist(to_cast))
		if(to_cast.len)
			var/delay_from_spells = 0

			next_cur_mod_cycle = FALSE
			var/i = 1
			for(var/obj/item/spell/S in to_cast)
				if(!S.stackable)
					next_cur_mod_cycle = TRUE
				delay_from_spells += S.additional_delay * cur_mod.mult_delay + cur_mod.add_delay
				if(S.spell_can_cast(src, casting_obj, targets, cur_mod))
					INVOKE_ASYNC(S, /obj/item/spell.proc/cast, cast_type, src, casting_obj, targets, cur_mod, next_mod, i)
				i++

			if(always_casts)
				INVOKE_ASYNC(always_casts, /obj/item/spell.proc/cast, cast_type, src, casting_obj, targets, cur_mod, next_mod, i)
				if(!always_casts.stackable)
					next_cur_mod_cycle = TRUE

			var/cooldown = spell_cast_delay * cur_mod.mult_delay + cur_mod.add_delay + delay_from_spells
			display_spell_cooldown(cooldown)
			next_spell_cast = world.time + cooldown
			addtimer(CALLBACK(src, .proc/display_spell_readiness), cooldown)

	if(next_cur_mod_cycle)
		cur_mod = next_mod
		next_mod = get_default_cast_modifier()

/obj/item/weapon/wand/afterattack(atom/target, mob/living/user, proximity, params)
	if(enchanted)
		..()
		return

	if(proximity)
		if(wand_component_flags[WAND_COMP_ENCHANTCAST])
			try_casting(WAND_COMP_ENCHANTCAST, list(target), user)
			return

		if(wand_component_flags[WAND_COMP_MELEECAST] || wand_component_flags[WAND_COMP_SELFCAST])
			if(next_spell_cast > world.time)
				to_chat(user, "<span class='warning'>[src] is not yet ready to cast.</span>")
				return
			var/cast_type
			if(target == user)
				if(!wand_component_flags[WAND_COMP_SELFCAST])
					to_chat(user, "<span class='notice'>With [src], thee can not cast unto thyself.</span>")
					return
				cast_type = WAND_COMP_SELFCAST
			else
				if(!wand_component_flags[WAND_COMP_OTHERSCAST])
					to_chat(user, "<span class='notice'>With [src], thee can not cast unto others.</span>")
					return
				cast_type = WAND_COMP_OTHERSCAST
			try_casting(cast_type, list(target), user)
			return

		var/something_happened = FALSE
		if(user.a_intent == I_HURT)
			something_happened = TRUE
			..()

		if(wand_component_flags[WAND_COMP_MELEEMAGICCAST])
			if(next_spell_cast > world.time)
				to_chat(user, "<span class='warning'>[src] is not yet ready to cast.</span>")
				return

			something_happened = TRUE
			if(target == user && !wand_component_flags[WAND_COMP_SELFCAST])
				to_chat(user, "<span class='notice'>With [src], thee can not cast unto thyself.</span>")
				return

			try_casting(WAND_COMP_MELEEMAGICCAST, list(target), user)

		if(!something_happened)
			to_chat(user, "<span class='notice'>[src] seems to lack any components for close-quarters casting.</span>")
			return

		return

	if(next_spell_cast > world.time)
		to_chat(user, "<span class='warning'>[src] is not yet ready to cast.</span>")
		return

	var/cast_type
	if(target == user)
		if(!wand_component_flags[WAND_COMP_SELFCAST])
			to_chat(user, "<span class='notice'>With [src], thee can not cast unto thyself.</span>")
			return
		cast_type = WAND_COMP_SELFCAST
	else
		if(!wand_component_flags[WAND_COMP_OTHERSCAST])
			to_chat(user, "<span class='notice'>With [src], thee can not cast unto distance.</span>")
			return
		cast_type = WAND_COMP_OTHERSCAST

	try_casting(cast_type, list(target), user)

/obj/item/weapon/wand/onUserMouseDrop(atom/target, atom/dropping, mob/user)
	if(enchanted)
		return ..()

	if(wand_component_flags[WAND_COMP_MELEEMAGICCAST])
		return ..() // Process sweeps.

	if(!wand_component_flags[WAND_COMP_AREACAST])
		return FALSE

	if(user.next_move > world.time)
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(next_spell_cast > world.time)
		to_chat(user, "<span class='warning'>[src] is not yet ready to cast.</span>")
		return FALSE

	var/turf/target_turf = get_turf(target)
	var/turf/dropping_turf = get_turf(dropping)

	if(!istype(target_turf) || !istype(dropping_turf))
		return FALSE

	var/list/turfs = getline(dropping_turf, target_turf)
	try_casting(WAND_COMP_AREACAST, turfs, user)

	return TRUE

/obj/item/weapon/wand/proc/enchant_self()
	set name = "Enchant self"
	set desc  = "Attempt to enchant the wand with a spell."
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	if(!wand_component_flags[WAND_COMP_ENCHANTCAST])
		to_chat(usr, "<span class='notice>[src] can not be enchanted because [src] has not an enchantment component.</span>")
		return
	if(!wand_component_flags[WAND_COMP_SELFCAST])
		to_chat(usr, "<span class='notice'>[src] can not cast enchantments onto itself.<span>")
		return
	try_casting(WAND_COMP_ENCHANTCAST, list(src), usr)

/obj/item/weapon/wand/verb/spell_reload()
	set name = "Reload spell queue"
	set desc = "Forcibly reloads the spell queue."
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	try_reload(usr)

/obj/item/weapon/wand/ui_action_click()
	if(wand_component_flags[WAND_COMP_ENCHANTCAST])
		if(!wand_component_flags[WAND_COMP_SELFCAST])
			to_chat(usr, "<span class='notice'>[src] can not cast enchantments onto itself.<span>")
			return
		try_casting(WAND_COMP_ENCHANTCAST, list(src), usr)
		return
	attack_self(usr)
