/atom/proc/conjured_dissapear()
	density = FALSE

	visible_message("[bicon(src)]<span class='warning'>[src] begins to shake violently, floating up in the air!</span>")
	animate(src, pixel_y=pixel_y+16, time=6)
	sleep(6)
	if(QDELING(src))
		return
	var/tremble = rand(1, 12)
	for(var/i in 1 to tremble)
		var/matrix/M = matrix()
		M.Turn(rand(-45, 45))
		animate(src, transform=M, time=2)
		sleep(2)
		if(QDELING(src))
			return
	qdel(src)

/obj/item/spell/conjure
	category = "Conjure"

	var/list/to_spawn
	var/time_to_live = -1 // -1 means forever.

/obj/item/spell/conjure/proc/get_conj_loc(obj/item/weapon/wand/holder, atom/casting_obj, atom/target)
	return get_turf(target)

/obj/item/spell/conjure/proc/get_to_spawn()
	return to_spawn

/obj/item/spell/conjure/proc/get_amount(def_am, mult_am, add_am)
	return round((def_am * mult_am) + add_am)

/obj/item/spell/conjure/proc/conjure_entities(atom/conj_loc, atom/casting_obj, mult_am, add_am)
	. = list()
	var/list/try_spawning = get_to_spawn()
	for(var/entity_type in try_spawning)
		var/am = get_amount(try_spawning[entity_type], mult_am, add_am)
		if(am > 0)
			for(var/i in 1 to am)
				. += new entity_type(conj_loc)

/obj/item/spell/conjure/proc/modify_entity(atom/ent, obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(time_to_live >= 0.0)
		var/to_live = (time_to_live * cur_mod.mult_power) + cur_mod.add_power
		addtimer(CALLBACK(ent, /atom.proc/conjured_dissapear), to_live)

/obj/item/spell/conjure/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/atom/conj_loc = get_conj_loc(holder, casting_obj, target)
	var/list/spawned = conjure_entities(conj_loc, casting_obj, cur_mod.mult_power, cur_mod.add_power)
	for(var/atom/A in spawned)
		modify_entity(A, holder, casting_obj, target, cur_mod, next_mod)
