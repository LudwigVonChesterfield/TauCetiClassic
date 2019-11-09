/datum/reagent
	var/mana_per_unit = 0.0

/datum/reagent/gold
	mana_per_unit = 5.0

/datum/reagent/silver
	mana_per_unit = 3.0

/datum/reagent/iron
	mana_per_unit = 2.0

/datum/reagent/steel
	mana_per_unit = 1.5

/datum/reagent/stone
	mana_per_unit = 1.0

/datum/reagent/blood
	mana_per_unit = 1.0



/datum/reagent/mana
	name = "Mana"
	id = "mana"
	description = "An essence of magic."
	reagent_state = LIQUID
	color = "#001c99" // rgb: 0, 28, 153
	taste_message = "<font color='purple'>magic</font>"

	// 1 unit of mana is 1 wand mana.
	custom_metabolism = 1

	density = 1.0

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 1.0,
	                         "other" = 0.0)
	data = 0

/datum/reagent/mana/on_general_digest(mob/living/M)
	..()
	// Toxins are really weak, but without being treated, last very long.
	var/obj/item/weapon/wand/W = M.get_active_hand()
	if(istype(W))
		if(W.mana >= W.max_mana)
			/*
				Do a mana explosion or something, to fuck 'em metagamers up.
			*/
			data++
			if(data > 13)
				explosion(get_turf(M), 0.0, 1.0, 2.0, 0.0)
			else if(data > 10)
				var/obj/effect/effect/sparks/S = new /obj/effect/effect/sparks(M.loc)
				S.color = TO_GREYSCALE_AND_APPLY(0, 28, 153)
		W.adjust_mana(1)
