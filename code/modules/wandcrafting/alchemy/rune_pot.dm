#define DUST_AM_PER_RUNE 5.0
#define MANA_PER_RUNE 10.0
#define POT_IGNITION_TEMP 1000

/obj/item/empty_rune
	name = "empty rune"
	desc = "A rune, yet to be filled with potent scribings."
	icon = 'icons/obj/spell_runes.dmi'
	icon_state = "rune_rock_1"

	w_class = ITEM_SIZE_SMALL

	spawn_destruction_reagents = list("stone" = 5.0)

/obj/item/empty_rune/atom_init()
	. = ..()
	icon_state = "rune_rock_[rand(1, 6)]"



/obj/structure/rune_pot
	name = "runic pot"
	desc = "You can cook mana and runes in it."

	icon = 'icons/obj/spell_structures.dmi'
	icon_state = "pot"

	density = TRUE
	anchored = TRUE

	flags = OPENCONTAINER

	spawn_destruction_reagents = list("stone" = 90, "wood" = 10)

	var/my_reag_color = ""

	var/amount_per_transfer_from_this = 1
	var/possible_transfer_amounts = list(1, 5, 10, 25, 50, 100)

	var/lit = FALSE

/obj/structure/rune_pot/atom_init()
	create_reagents(1000)
	if(!possible_transfer_amounts)
		verbs -= /obj/structure/rune_pot/verb/set_APTFT
	return ..()

/obj/structure/rune_pot/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)

	var/N = input("Amount per transfer from this:", "[src]") as null|anything in possible_transfer_amounts
	if(N)
		amount_per_transfer_from_this = N

/obj/structure/rune_pot/examine(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>The solution inside is somewhere <span color=[my_reag_color]>like this</span> in color.</span>")
	if(isliving(user))
		user.taste_reagents(reagents, "smell")

/obj/structure/rune_pot/on_reagent_change()
	my_reag_color = mix_color_from_reagents(reagents.reagent_list)

	var/bubbles_am = round(reagents.total_volume * 0.1, 1.0)
	if(bubbles_am >= 1.0)
		var/image/bubble = image(icon=icon, icon_state="pot_bubble")
		bubble.pixel_x = rand(-10, 10)
		bubble.color = my_reag_color
		flick_overlay(bubble, get_mob_with_client_list(), 1 SECOND)

/obj/structure/rune_pot/attackby(obj/item/I, mob/user)
	if(lit)
		if(istype(I, /obj/item/weapon/wand))
			user.SetNextMove(CLICK_CD_MELEE)
			var/mana_catalyst_am = reagents.get_reagent_amount("mana_catalyst")
			if(mana_catalyst_am > 0.0)
				user.visible_message("<span class='notice'>[src] pops, as it's turn a shade of blue...</span>")

				var/to_convert = mana_catalyst_am
				var/list/reags_to_pick = list() + reagents.reagent_list
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
					reagents.remove_reagent(R.id, converted)
					reagents.add_reagent("mana", new_mana_amount)

				// A little screw-up mechanic.
				// If there is no enough catalyst for all the reagents inside, create ectoplasm, and evaporate everything.
				if(reagents.total_volume >= 0.0)
					var/ectoplasm_am = 0.0
					for(var/datum/reagent/R in reagents.reagent_list)
						if(R.id == "mana" || R.id == "mana_catalyst")
							continue
						if(R.mana_per_unit == 0.0)
							continue
						ectoplasm_am += R.volume * R.mana_per_unit
						reagents.remove_reagent(R.id, R.volume)

					if(ectoplasm_am > 0.0)
						reagents.add_reagent("ectoplasm", ectoplasm_am)

						var/datum/reagents/evaporate = new /datum/reagents
						evaporate.my_atom = src // Important for fingerprint tracking, and etc.

						reagents.trans_to(evaporate, reagents.total_volume)

						if(evaporate.reagent_list.len)
							var/location = get_turf(src)
							var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
							S.attach(location)
							S.set_up(evaporate, CLAMP(evaporate.total_volume * 0.1, 1, 10), 0, location)
							playsound(location, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
							S.start()

						var/obj/effect/effect/sparks/SP = new /obj/effect/effect/sparks(loc)
						SP.color = TO_GREYSCALE_AND_APPLY(255, 168, 228)
					else
						var/obj/effect/effect/sparks/SP = new /obj/effect/effect/sparks(loc)
						SP.color = TO_GREYSCALE_AND_APPLY(0, 28, 153)


			// reagents.update_total()
			// reagents.handle_reactions()
			return

		else if(istype(I, /obj/item/dust))
			user.SetNextMove(CLICK_CD_MELEE)
			var/obj/item/dust/D = I

			user.visible_message("<span class='notice'>[user] puts [D] into [src].</span>",
				"<span class='notice'>You put [D] into [src].</span>")
			new /obj/effect/effect/sparks(loc)

			while(D.reagents.total_volume >= DUST_AM_PER_RUNE && reagents.get_reagent_amount("mana") >= MANA_PER_RUNE)
				new /obj/item/empty_rune(loc)
				reagents.remove_reagent("mana", MANA_PER_RUNE)
				D.reagents.remove_any(DUST_AM_PER_RUNE)

			qdel(D)
			return

		else if(istype(I, /obj/item/empty_rune))
			if(reagents.total_volume == 0.0)
				return

			user.SetNextMove(CLICK_CD_MELEE)
			var/cur_mix_color = mix_color_from_reagents(reagents.reagent_list)

			user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>",
			"<span class='notice'>You put [I] into [src].</span>")

			var/obj/effect/effect/sparks/SP = new /obj/effect/effect/sparks(loc)
			var/list/cur_mix_rgb = ReadRGB(cur_mix_color)
			SP.color = TO_GREYSCALE_AND_APPLY(cur_mix_rgb[1], cur_mix_rgb[2], cur_mix_rgb[3])

			var/rune_color = ""
			if(global.color_to_approx_rune_color[cur_mix_color])
				rune_color = global.color_to_approx_rune_color[cur_mix_color]
			else

				var/list/closest_approx_cols
				var/closest_approx_dist = sqrt((255^2) * 3)

				for(var/pos_rune_color in global.spell_colors_to_use)
					var/list/pos_mix_rgb = ReadRGB(pos_rune_color)

					var/dist = 0
					for(var/i in 1 to pos_mix_rgb.len)
						dist += (pos_mix_rgb[i] - cur_mix_rgb[i])^2
					dist = sqrt(dist)

					if(dist <= closest_approx_dist)
						closest_approx_dist = dist
						if(closest_approx_cols)
							closest_approx_cols += pos_rune_color
						else
							closest_approx_cols = list(pos_rune_color)
				rune_color = pick(closest_approx_cols)
				global.color_to_approx_rune_color[cur_mix_color] = rune_color

			new /obj/item/rune(loc, list(pick(global.color_to_runes[rune_color])))
			qdel(I)

			reagents.clear_reagents()
			return

	else if(iswrench(I))
		if(user.is_busy())
			return
		if(lit)
			return
		user.SetNextMove(CLICK_CD_MELEE)
		if(anchored)
			user.visible_message("[user] unsecures \the [src].", "You start to unsecure \the [src] from the floor.")
		else
			user.visible_message("[user] secures \the [src].", "You start to secure \the [src] to the floor.")

		if(I.use_tool(src, user, 40, volume = 50))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secured \the [src]!</span>")
			anchored = !anchored
	/*
	else if(I.open_container() && I.reagents)
		if(user.a_intent == I_GRAB)
			reagents.trans_to(I, amount_per_transfer_from_this)
		else
			I.reagents.trans_to(src, amount_per_transfer_from_this)
	*/
	else
		var/temp = I.get_current_temperature()
		if(temp >= POT_IGNITION_TEMP)
			user.SetNextMove(CLICK_CD_MELEE)
			user.visible_message("<span class='notice'>[user] lights [src] with [I].</span>")
			lit = TRUE
			icon_state = "pot_lit"

			reagents.update_total()
			reagents.handle_reactions()

			return
		..()

/obj/structure/rune_pot/MouseDrop_T(atom/target, mob/user)
	if(!user.incapacitated())
		if(target == user)
			var/obj/item/I = user.get_active_hand()
			if(I && I.is_open_container())
				visible_message("<span class='notice'>[user] spills contents of [src] into [I].</span>")
				reagents.trans_to(I, amount_per_transfer_from_this)
		else if(target.reagents && target.is_open_container())
			visible_message("<span class='notice'>[user] spills contents of [src] into [target].</span>")
			reagents.trans_to(target, amount_per_transfer_from_this)

#undef DUST_AM_PER_RUNE
#undef MANA_PER_RUNE
#undef POT_IGNITION_TEMP
