/datum/reagents/proc/on_magic_cast(obj/item/weapon/wand/W, obj/item/spell/S)
	if(!my_atom)
		return

	var/mana_catalyst_am = get_reagent_amount("mana_catalyst")
	if(mana_catalyst_am > 0.0)
		my_atom.visible_message("<span class='notice'>[my_atom] pops, as it's turn a shade of blue...</span>")

		var/to_convert = mana_catalyst_am
		var/list/reags_to_pick = list() + reagent_list
		while(to_convert > 0.0)
			if(reags_to_pick.len == 0)
				break
			var/datum/reagent/R = pick(reags_to_pick)
			if(R.id == "mana" || R.id == "mana_catalyst")
				reags_to_pick -= R
				continue

			var/converted = min(max(rand(10, to_convert * 10) * 0.1, 0.1), R.volume)
			to_convert -= converted

			var/new_mana_amount = converted * R.mana_per_unit
			if(converted == R.volume)
				reags_to_pick -= R
			remove_reagent(R.id, converted)
			add_reagent("mana", new_mana_amount)

		// A little screw-up mechanic.
		// If there is not enough catalyst for all the reagents inside, create ectoplasm, and evaporate everything.
		if(total_volume >= 0.0)
			var/ectoplasm_am = 0.0
			for(var/datum/reagent/R in reagent_list)
				if(R.id == "mana" || R.id == "mana_catalyst")
					continue
				if(R.mana_per_unit == 0.0)
					continue
				ectoplasm_am += R.volume * R.mana_per_unit
				remove_reagent(R.id, R.volume)

			if(ectoplasm_am > 0.0)
				add_reagent("ectoplasm", ectoplasm_am)

				var/datum/reagents/evaporate = new /datum/reagents
				evaporate.my_atom = src // Important for fingerprint tracking, and etc.

				trans_to(evaporate, total_volume)

				if(evaporate.reagent_list.len)
					var/location = get_turf(my_atom)
					var/datum/effect/effect/system/smoke_spread/chem/CS = new /datum/effect/effect/system/smoke_spread/chem
					CS.attach(location)
					CS.set_up(evaporate, CLAMP(evaporate.total_volume * 0.1, 1, 10), 0, location)
					playsound(location, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
					CS.start()

					var/obj/effect/effect/sparks/SP = new /obj/effect/effect/sparks(my_atom.loc)
					SP.color = TO_GREYSCALE_AND_APPLY(255, 168, 228)
				else
					var/obj/effect/effect/sparks/SP = new /obj/effect/effect/sparks(my_atom.loc)
					SP.color = TO_GREYSCALE_AND_APPLY(0, 28, 153)
