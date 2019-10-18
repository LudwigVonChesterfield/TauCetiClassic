/datum/reagent/iron
	is_sharp = TRUE
	density = 3.0
	pressure_split = 9.0
	brittle_amount = 0.0

	damage_resistance = list(BRUTE = 0.25,
	                         BURN = 0.25,
	                         "other" = 0.25)

/datum/reagent/iron/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM, knocked_amount)
	. = ..()
	if(holder && knocked_amount >= 2.0 && DM.damage_type == BRUTE)
		new /obj/effect/effect/sparks(holder.my_atom)

/datum/reagent/steel
	name = "Steel"
	id = "steel"
	description = "Iron infused with hints of coal, which somehow makes it less brittle."
	reagent_state = SOLID
	color = "#5b5f63" // rgb: 91, 95, 99
	taste_message = "metal"

	is_sharp = TRUE
	density = 4.0
	pressure_split = 12.0
	brittle_amount = 0.0

	damage_resistance = list(BRUTE = 0.5,
	                         BURN = 0.5,
	                         "other" = 0.5)

/datum/reagent/fabric
	name = "Fabric"
	id = "fabric"
	description = "A whole bunch of fabric material neatly knitted together or something.."
	reagent_state = SOLID
	color = "#c28b78" // rgb: 194, 139, 120
	custom_metabolism = 0.01
	taste_message = "fabrics"

	density = 0.1
	pressure_split = 0.0
	brittle_amount = 10.0 // Only falls out in big chunks.

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.0,
	                         "other" = 0.0)

/datum/reagent/bananium
	name = "Bananium"
	id = "bananium"
	description = "HONK-ed."
	reagent_state = SOLID
	color = "#ffff00" // rgb: 255, 255, 0
	custom_metabolism = 0.01
	taste_message = "fear"

	density = 0.1
	pressure_split = 0.0
	brittle_amount = 10.0 // Only falls in big chunks.

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.0,
	                         "other" = 0.0)

/datum/reagent/plastic
	name = "Plastic"
	id = "plastic"
	description = "Solid plastic, do not eat."
	reagent_state = SOLID
	color = "#cf3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01
	taste_message = "plastic"

	density = 1.0
	pressure_split = 0.0
	brittle_amount = 5.0 // Only falls out in chunks.

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.7,
	                         "other" = 0.7)

/datum/reagent/plasteel
	name = "Plasteel"
	id = "plasteel"
	description = "A mix of ferum, carbon, and whatever you get from snorting oil. Extremely cool, yet lightweight."
	reagent_state = SOLID
	color = "#917b77" // rgb: 145, 123, 119
	custom_metabolism = 0.01
	taste_message = "smelly metal"

	is_sharp = TRUE
	density = 4.0
	pressure_split = 12.0
	brittle_amount = 5.0 // Only falls out in chunks.

	damage_resistance = list(BRUTE = 0.5,
	                         BURN = 0.7,
	                         "other" = 0.7)

/datum/reagent/gold
	density = 4.0
	pressure_split = 12.0
	brittle_amount = 0.0

	damage_resistance = list(BRUTE = 0.4,
	                         BURN = 0.0,
	                         "other" = 0.4)

/datum/reagent/diamond
	name = "Diamond"
	id = "diamond"
	description = "A blue, shiny rock."
	reagent_state = SOLID
	color = "#c2fdff" // rgb: 194, 253, 255
	taste_message = "diamond"

	density = 5.0
	pressure_split = 12.0 // You need a lot of pressure to split off a diamond piece.
	brittle_amount = 5.0

	damage_resistance = list(BRUTE = 0.5,
	                         BURN = 0.7,
	                         "other" = 0.0)

/datum/reagent/silver
	density = 2.5
	pressure_split = 7.5
	brittle_amount = 0.0

	damage_resistance = list(BRUTE = 0.3,
	                         BURN = 0.3,
	                         "other" = 0.3)

/datum/reagent/uranium
	density = 3.5
	pressure_split = 10.5
	brittle_amount = 1.0

	damage_resistance = list(BRUTE = 0.3,
	                         BURN = 1.0,
	                         "other" = 0.3)

/datum/reagent/aluminum
	density = 0.8
	pressure_split = 2.4
	brittle_amount = 0.0

	is_sharp = TRUE
	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.0,
	                         "other" = 0.0)

/datum/reagent/silicon
	density = 0.7
	pressure_split = 2.1
	brittle_amount = 1.0

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.0,
	                         "other" = 0.5)

/datum/reagent/sandstone
	name = "Sandstone"
	id = "sandstone"
	description = "A stone of sand."
	reagent_state = SOLID
	color = "#d1ca82" // rgb: 209, 202, 130
	taste_message = "beach"

	density = 2.5
	pressure_split = 7.5
	brittle_amount = 5.0

	damage_resistance = list(BRUTE = 0.5,
	                         BURN = 0.5,
	                         "other" = 0.0)

/datum/reagent/wood
	name = "Wood"
	id = "wood"
	description = "It probably can give you splinters."
	reagent_state = SOLID
	color = "#cf3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01
	taste_message = "plastic"

	density = 1.0
	pressure_split = 3.0
	brittle_amount = 2.0 // Only falls in splinters.

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 0.0,
	                         "other" = 0.5)

/datum/reagent/glass
	name = "Glass"
	id = "glass"
	description = "A not-so-transparent glass solid."
	reagent_state = SOLID
	color = "#b8e0f2" // rgb: 184, 224, 242
	custom_metabolism = 0.01

	taste_strength = 0

	is_brittle = TRUE
	is_sharp = TRUE

	density = 0.3
	pressure_split = 0.0
	brittle_amount = 5.0 // Only falls out in chunks.

	damage_resistance = list(BRUTE = 0.0,
	                         BURN = 1.0,
	                         "other" = 0.0)
