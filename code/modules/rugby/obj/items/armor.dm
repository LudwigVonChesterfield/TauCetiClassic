/obj/item/clothing/suit/armor/rugby
	name = "rugby armor"
	desc = "For when you know you gotta tackle some dudes."

	icon = 'code/modules/rugby/icons/clothing.dmi'
	icon_custom = 'code/modules/rugby/icons/clothing.dmi'

	armor = list(melee = 50, bullet = 10, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

	var/image/num_overlay
	var/number

/obj/item/clothing/suit/armor/rugby/proc/get_team()
	return null

/obj/item/clothing/suit/armor/rugby/equipped(mob/user, slot)
	if(slot == SLOT_WEAR_SUIT)
		var/datum/team/T = get_team()
		var/n = 0
		if(T)
			for(var/datum/player/P in T.players)
				if(P == user)
					n = P.number
					break
		set_number(n)
	else
		set_number(0)

/obj/item/clothing/suit/armor/rugby/dropped(mob/user)
	set_number(0)

/obj/item/clothing/suit/armor/rugby/proc/set_number(number)
	if(src.number == 0)
		return

	overlays -= num_overlay
	QDEL_NULL(num_overlay)

	if(number == 0)
		return

	src.number = number
	num_overlay = image(icon='code/modules/rugby/icons/clothing.dmi', icon_state="armor_[number]")
	overlays += num_overlay

/obj/item/clothing/suit/armor/rugby/red
	icon_state = "red_armor"

/obj/item/clothing/suit/armor/rugby/red/get_team()
	return match.red

/obj/item/clothing/suit/armor/rugby/blue
	icon_state = "blue_armor"

/obj/item/clothing/suit/armor/rugby/blue/get_team()
	return match.blue



/obj/item/clothing/under/rugby
	name = "rugby uniform"
	desc = "An iconic uniform to symbolise that you are gonna get smashed by a bunch of sweaty men."

	icon_custom = 'code/modules/rugby/icons/clothing.dmi'

	var/image/num_overlay
	var/number

/obj/item/clothing/under/rugby/proc/get_team()
	return null

/obj/item/clothing/under/rugby/equipped(mob/user, slot)
	if(slot == SLOT_W_UNIFORM)
		var/datum/team/T = get_team()
		var/n = 0
		for(var/datum/player/P in T.players)
			if(P == user)
				n = P.number
				break
		set_number(n)
	else
		set_number(0)

/obj/item/clothing/under/rugby/dropped(mob/user)
	set_number(0)

/obj/item/clothing/under/rugby/proc/set_number(number)
	if(src.number == 0)
		return

	overlays -= num_overlay
	QDEL_NULL(num_overlay)

	if(number == 0)
		return

	src.number = number
	num_overlay = image(icon='code/modules/rugby/icons/clothing.dmi', icon_state="shirt_[number]")
	overlays += num_overlay

/obj/item/clothing/under/rugby/red
	icon_state = "red_shirt"

/obj/item/clothing/under/rugby/red/get_team()
	return match.red

/obj/item/clothing/under/rugby/blue
	icon_state = "blue_shirt"

/obj/item/clothing/under/rugby/blue/get_team()
	return match.blue



/obj/item/clothing/shoes/rugby
	name = "sneakers"