var/global/icon/diona_filter_icon = icon('icons/misc/tools.dmi', "diona_filter")


/proc/add_diona_filter(image/I)
	I.filters += filter(
		type="layer",
		// Randomising these would make every dionified item look different(if dionification texture is big enough to offset it)
		x=0,
		y=0,
		icon=diona_filter_icon,
		blend_mode=BLEND_MULTIPLY,
	)


/obj/item
	var/dionified = FALSE

/obj/item/proc/poke_nymph()
	set name = "Poke"
	set category = "Object"
	set src in usr

	qdel(src)

/obj/item/proc/copy_item_icon_info(obj/item/copying_from)
	icon = copying_from.icon
	icon_state = copying_from.icon_state
	item_state = copying_from.item_state
	lefthand_file = copying_from.lefthand_file
	righthand_file = copying_from.righthand_file
	icon_override = copying_from.icon_override
	transform = copying_from.transform
	pixel_x = copying_from.pixel_x
	pixel_y = copying_from.pixel_y

	slot_flags = copying_from.slot_flags

// Returns an item to be dionified, somehow based on base item's functionality (or not)
/obj/item/proc/get_diona_simulacrum()
	return new /obj/item()

// Makes the item a pretty and wooden copy of another item.
/obj/item/proc/dionify(obj/item/target)
	unacidable = FALSE

	dionified = TRUE
	// Wood does not conduct electriciy.
	flags &= ~(CONDUCT)

	var/datum/species/diona/D
	siemens_coefficient = initial(D.siemens_coefficient)

	// Get some whoosh-whoosh sound.
	hitsound = 'sound/weapons/slice.ogg'
	can_embed = FALSE

	// The thing's wooden, it never will be sharp.
	damtype = "brute"

	force *= 0.5
	sharp = FALSE
	edge = FALSE

	// And never will fly fast!
	throwforce *= 0.5
	throw_speed *= 0.5
	throw_range *= 0.5

	m_amt = 0
	g_amt = 0

	attack_verb = list("hit", "bludgeon")

	max_heat_protection_temperature = initial(D.heat_level_3)
	min_cold_protection_temperature = initial(D.cold_level_3)

	// It's made out of "wood"! It's got to be heavy.
	slowdown += 1

	// Copying a toolbox shouldn't copy it's contents.
	// arguable, because perhaps the contents are a battery?
	for(var/obj/item/I in contents)
		qdel(I)

	if(reagents)
		reagents.clear_reagents()

	return src

/obj/item/clothing/dionify(obj/item/target)
	return ..()

#define SIMULACRUM_RETURN_SELF_TYPE(TYPE) \
##TYPE/get_diona_simulacrum()\
	return new TYPE()

SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/ears)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/glasses)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/gloves)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/head)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/mask)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/shoes)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/suit)
SIMULACRUM_RETURN_SELF_TYPE(/obj/item/clothing/under)

#undef SIMULACRUM_RETURN_SELF_TYPE

/obj/item/clothing/under/get_diona_simulacrum()
	return new /obj/item/clothing/under/diona()

/obj/item/clothing/under/diona/can_attach_accessory(obj/item/clothing/accessory/A)
	return FALSE
