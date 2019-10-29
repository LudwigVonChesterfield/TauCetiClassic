#define RUNE_SLOTS 13
#define MAX_RUNES_IN_FORGE MAX_RUNES * RUNE_SLOTS

/obj/structure/rune_forge
	name = "runic forge"
	desc = "Put runes in it, and it shall try to combine them into something meaningful."

	icon = 'icons/obj/spell_structures.dmi'
	icon_state = "forge"

	var/processing = FALSE

	var/obj/item/weapon/storage/internal/updating/rune_storage

	density = TRUE

	spawn_destruction_reagents = list("stone" = 80, "iron" = 20)

/obj/structure/rune_forge/atom_init(mapload)
	. = ..()

	rune_storage = new(src)
	rune_storage.set_slots(slots = RUNE_SLOTS, slot_size = ITEM_SIZE_SMALL)
	rune_storage.can_hold = list(/obj/item/rune)

	update_icon()

/obj/structure/rune_forge/Destroy()
	QDEL_NULL(rune_storage)
	return ..()

/obj/structure/rune_forge/proc/combine_runes(obj/item/rune/R1, obj/item/rune/R2)
	return R1.merge_with(R2)

/obj/structure/rune_forge/proc/split_rune(obj/item/rune/R)
	R.on_destroy()

// Returns either null, or a list of spell types.
/obj/structure/rune_forge/proc/get_spells(obj/item/rune/R)
	return global.spell_types_by_spell_word[R.rune_word]

/obj/structure/rune_forge/proc/combine()
	processing = TRUE
	visible_message("<span class='notice'>[src] clings, as it starts up.</span>")

	rune_storage.close_all()
	for(var/obj/item/rune/R in contents)
		if(get_spells(R) && rune_storage.can_be_inserted(R))
			rune_storage.handle_item_insertion(R)

	for(var/obj/item/rune/R in rune_storage.contents)
		if(!get_spells(R)) // Don't ruin a perfectly good rune.
			R.forceMove(src) // Runes that are not yet "good" are stored inside the forge.

	var/list/runes_singleton = list()

	var/some_split = TRUE
	while(some_split)
		some_split = FALSE

		var/list/to_check = list() + contents

		for(var/obj/item/rune/R in to_check)
			if(R.runes.len > 1)
				R.on_destroy()
				some_split = TRUE

				if(prob(20))
					if(prob(50))
						visible_message("<span class='notice'>[src] clangs loudly!</span>")
					new /obj/effect/effect/sparks(loc)

				sleep(3)
				if(QDELING(src))
					return
			else
				runes_singleton += R
				R.forceMove(null)

	var/list/runes_by_rune_word = list()
	var/list/available_runes = list()

	for(var/obj/item/rune/R in runes_singleton)
		var/rune = lowertext(R.rune_word)
		R.forceMove(src)
		available_runes += rune
		if(runes_by_rune_word[rune])
			runes_by_rune_word[rune] += R
		else
			runes_by_rune_word[rune] = list(R)

	var/list/available_spells = list()

	for(var/spell_word in global.runes_by_spell_word)
		var/list/spell_runes = global.runes_by_spell_word[spell_word]
		var/is_available = TRUE
		availability_loop:
			for(var/spell_rune in spell_runes)
				if(!(spell_rune in available_runes))
					is_available = FALSE
					break availability_loop

		if(is_available)
			for(var/spell_rune in spell_runes)
				available_runes -= spell_rune
			available_spells += spell_word

	add_loop:
		while(rune_storage.contents.len < RUNE_SLOTS)
			if(available_spells.len == 0)
				break

			sleep(3)
			if(QDELING(src))
				return

			var/add_spell = pick(available_spells)
			available_spells -= add_spell

			var/obj/item/rune/master_rune

			rune_word_loop:
				for(var/rune_word in global.runes_by_spell_word[add_spell])
					if(!runes_by_rune_word[rune_word])
						break rune_word_loop
					var/obj/item/rune/R = pick(runes_by_rune_word[rune_word])
					runes_by_rune_word[rune_word] -= R
					if(runes_by_rune_word[rune_word].len == 0)
						runes_by_rune_word -= rune_word

					if(prob(20))
						if(prob(50))
							visible_message("<span class='notice'>[src] clings loudly!</span>")
						new /obj/effect/effect/sparks(loc)

					if(!master_rune)
						master_rune = R
					else
						var/obj/item/rune/temp = combine_runes(master_rune, R)
						if(temp)
							master_rune = temp
						else
							break rune_word_loop

			if(master_rune && get_spells(master_rune))
				if(rune_storage.can_be_inserted(master_rune))
					if(prob(20))
						if(prob(50))
							visible_message("<span class='notice'>[src] creaks loudly!</span>")
						new /obj/effect/effect/smoke(loc)
					rune_storage.handle_item_insertion(master_rune)
				else
					break add_loop

	while(contents.len > MAX_RUNES_IN_FORGE)
		var/obj/item/rune/scape_goat = pick(contents)
		qdel(scape_goat)

	visible_message("<span class='notice'>[src] clangs, as it stops.</span>")
	processing = FALSE

/obj/structure/rune_forge/verb/start_combining()
	set name = "Start Rune Combining Procedure"
	set desc = "Starts the rune combining procedure."
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		return

	if(processing)
		return

	combine()

/obj/structure/rune_forge/attack_hand(mob/living/user)
	if(!processing && !user.incapacitated())
		user.SetNextMove(CLICK_CD_MELEE)
		rune_storage.open(user)
		..()

/obj/structure/rune_forge/MouseDrop_T(mob/living/target, mob/user)
	if(!processing && !user.incapacitated() && target == user)
		rune_storage.open(user)

/obj/structure/rune_forge/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		if(user.is_busy())
			return
		if(anchored)
			user.visible_message("[user] unsecures \the [src].", "You start to unsecure \the [src] from the floor.")
		else
			user.visible_message("[user] secures \the [src].", "You start to secure \the [src] to the floor.")

		if(I.use_tool(src, user, 40, volume = 50))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secured \the [src]!</span>")
			anchored = !anchored
	else
		if(rune_storage.can_be_inserted(I))
			rune_storage.handle_item_insertion(I)
			return
		..()

#undef RUNE_SLOTS
#undef MAX_RUNES_IN_FORGE
