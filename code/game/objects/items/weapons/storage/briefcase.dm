/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/briefcase/attack(mob/living/M, mob/living/user)
	//..()

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Paralyse(2)
		return


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])", user)

	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != DEAD)	M.stat = UNCONSCIOUS

		visible_message("<span class='warning'><B>[M] has been knocked unconscious!</B></span>", blind_message = "<span class='warning'>You hear someone fall.</span>")
	else
		to_chat(M, text("<span class='warning'>[] tried to knock you unconcious!</span>",user))
		M.eye_blurry += 3

	return

/obj/item/weapon/storage/briefcase/centcomm
	icon_state = "briefcase-centcomm"
	item_state = "briefcase-centcomm"


/obj/item/weapon/storage/briefcase/surgery
	name = "surgeon tray"
	icon_state = "case-surgery"
	item_state = "case-surgery"
	desc = "This is a surgical tray made of stainless steel, the label on the lid reads: Made by Vey Med Corp. 2189 year."
	max_storage_space = 18
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/bottle,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/gloves/latex,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/weapon/retractor,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/cautery,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/weapon/bonesetter
		)

/obj/item/weapon/storage/briefcase/surgery/atom_init()
	. = ..()
	use_sound = "sound/items/surgery_tray.ogg"

/obj/item/weapon/storage/briefcase/surgery/full

/obj/item/weapon/storage/briefcase/surgery/full/atom_init()
	. = ..()
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/bonesetter(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/FixOVein(src)