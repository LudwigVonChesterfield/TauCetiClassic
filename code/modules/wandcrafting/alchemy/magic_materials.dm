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



/datum/reagent/mana
	name = "Mana"
	id = "mana"
	description = "An essence of magic."
	reagent_state = LIQUID
	color = "#001c99" // rgb: 0, 28, 153
	taste_message = "<font color='purple'>magic</font>"

	density = 1.0

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 1.0,
	                         "other" = 0.0)
