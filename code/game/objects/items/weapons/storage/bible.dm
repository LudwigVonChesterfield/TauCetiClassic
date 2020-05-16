/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/mob/affecting = null
	var/deity_name = "Christ"
	var/god_lore = ""
	max_storage_space = DEFAULT_BOX_STORAGE

	var/religify_next = list()

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/atom_init()
	. = ..()
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(!user.mind || !user.mind.holy_role)
		return

	if(!global.chaplain_religion.faith_reactions.len)
		return

	var/chosen_reaction = input(user, "Choose a reaction that will partake in the container.", "A reaction.") as null|anything in global.chaplain_religion.faith_reactions
	if(!chosen_reaction)
		return
	if(!in_range(user, target))
		return
	if(!target.reagents)
		return

	var/datum/faith_reaction/FR = global.chaplain_religion.faith_reactions[chosen_reaction]
	FR.react(target, user)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W, mob/user)
	if (length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, null, -5)
	..()

/obj/item/weapon/storage/bible/attack_self(mob/user)
	if(user.mind && (user.mind.holy_role))
		if(religify_next[user.ckey] > world.time)
			to_chat(user, "<span class='warning'>You can't be changing the look of your entire church so often! Please wait about [round((religify_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
			return
		else if(global.chaplain_religion)
			change_chapel_looks(user)
			return

	return ..()

/obj/item/weapon/storage/bible/proc/change_chapel_looks(mob/user)
	var/done = FALSE
	var/changes = FALSE

	var/list/choices = list("Altar", "Pews", "Mat symbol")

	while(!done)
		if(!choices.len)
			done = TRUE
			break

		var/looks = input(user, "Would you like to change something about how your chapel looks?") as null|anything in choices
		if(!looks)
			done = TRUE
			break

		switch(looks)
			if("Altar")
				var/new_look = input(user, "Which altar style would you like?")  as null|anything in global.chaplain_religion.altar_info_by_name
				if(!new_look)
					continue

				global.chaplain_religion.altar_icon_state = global.chaplain_religion.altar_info_by_name[new_look]
				changes = TRUE
				choices -= "Altar"

			if("Pews")
				var/new_look = input(user, "Which pews style would you like?")  as null|anything in global.chaplain_religion.pews_info_by_name
				if(!new_look)
					continue

				global.chaplain_religion.pews_icon_state = global.chaplain_religion.pews_info_by_name[new_look]
				changes = TRUE
				choices -= "Pews"

			if("Mat symbol")
				var/new_mat = input(user, "Which mat symbol would you like?")  as null|anything in global.chaplain_religion.carpet_dir_by_name
				if(!new_mat)
					continue

				global.chaplain_religion.carpet_dir = global.chaplain_religion.carpet_dir_by_name[new_mat]
				changes = TRUE
				choices -= "Mat symbol"

	if(changes)
		religify_next[user.ckey] = world.time + 3 MINUTE
		global.chaplain_religion.religify_chapel()
