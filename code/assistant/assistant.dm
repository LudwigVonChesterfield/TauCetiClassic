#define MONKEY "monkey"

/datum/species/human/monkey
	name = MONKEY
	gender_limb_icons = FALSE
	has_gendered_icons = FALSE
	// fat_limb_icons = TRUE
	primitive = /mob/living/carbon/monkey
	unarmed_type = /datum/unarmed_attack/punch

	flags = list(
	,HAS_LIPS = TRUE
	,HAS_HAIR = TRUE
	,FACEHUGGABLE = TRUE
	,IS_SOCIAL = TRUE
	)

	min_age = 25
	max_age = 40

	is_common = TRUE

	icobase = 'code/assistant/r_monkey.dmi'

/datum/job/assistant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.set_species(MONKEY)
	H.mutations.Add(SMALLSIZE)
	H.regenerate_icons()
	H.h_style = "Bald"
	H.f_style = "Shaved"
	H.update_hair()
