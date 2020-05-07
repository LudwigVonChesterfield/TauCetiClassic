/*
 *	Absorbs /obj/item/weapon/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 *      Syndie Briefcase
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = TRUE
	// What is the briefcase code.
	var/l_code = null
	// What the player sees (*****)
	var/code = ""
	// The code actually entered.
	var/e_code = ""
	var/l_set = FALSE
	var/l_setshort = FALSE
	var/l_hacking = FALSE
	var/emagged = FALSE
	var/open = FALSE
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/weapon/storage/secure/atom_init()
	. = ..()

	// I used 10 since you crack each digit, not the whole password itself.
	AddComponent(/datum/component/authentication, "briefcase_password", 10, CALLBACK(src, .proc/get_password))

/obj/item/weapon/storage/secure/proc/get_password()
	return l_code

/obj/item/weapon/storage/secure/examine(mob/user)
	..()
	if(src in oview(1, user))
		to_chat(user, "The service panel is [src.open ? "open" : "closed"].")

/obj/item/weapon/storage/secure/attack_alien(mob/user)
	return attack_hand(user)

/obj/item/weapon/storage/secure/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/storage/secure/attackby(obj/item/weapon/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/weapon/melee/energy/blade) && (!src.emagged))
			emagged = 1
			user.SetNextMove(CLICK_CD_MELEE)
			src.add_overlay(image('icons/obj/storage.dmi', icon_sparking))
			sleep(6)
			cut_overlays()
			add_overlay(image('icons/obj/storage.dmi', icon_locking))
			locked = 0
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			to_chat(user, "You slice through the lock on [src].")
			return

		if (isscrewdriver(W))
			if(!user.is_busy(src) && W.use_tool(src, user, 20, volume = 50))
				src.open =! src.open
				to_chat(user, "<span class='notice'>You [src.open ? "open" : "close"] the service panel.</span>")
			return
		if ((ismultitool(W)) && (src.open == 1)&& (!src.l_hacking))
			user.show_message("<span class='warning'>Now attempting to reset internal memory, please hold.</span>", SHOWMSG_ALWAYS)
			src.l_hacking = 1
			if (!user.is_busy(src) && W.use_tool(src, usr, 100, volume = 50))
				if (prob(40))
					src.l_setshort = 1
					src.l_set = 0
					user.show_message("<span class='warning'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>", SHOWMSG_ALWAYS)
					sleep(80)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message("<span class='warning'>Unable to reset internal memory.</span>", SHOWMSG_ALWAYS)
					src.l_hacking = 0
			else	src.l_hacking = 0
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	// -> storage/attackby() what with handle insertion, etc
	..()

/obj/item/weapon/storage/secure/emag_act(mob/user)
	if(!locked || src.emagged)
		return FALSE
	emagged = 1
	user.SetNextMove(CLICK_CD_MELEE)
	src.add_overlay(image('icons/obj/storage.dmi', icon_sparking))
	sleep(6)
	cut_overlays()
	add_overlay(image('icons/obj/storage.dmi', icon_locking))
	locked = 0
	to_chat(user, "You short out the lock on [src].")
	return TRUE

/obj/item/weapon/storage/secure/MouseDrop(over_object, src_location, over_location)
	if (locked)
		src.add_fingerprint(usr)
		return
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = code
	if(!locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	user << browse(entity_ja(dat), "window=caselock;size=300x280")

/obj/item/weapon/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return

	if(href_list["type"])
		switch(href_list["type"])
			if("E")
				if(!l_set && length(e_code) == 5 && !l_setshort && code != "ERROR")
					l_code = e_code
					l_set = TRUE

					create_meme(/datum/meme/memory/password/case, "briefcase_password_" + l_code, l_code)
					usr.attach_meme("briefcase_password_" + l_code)

				else if(e_code == l_code && !emagged && l_set)
					locked = FALSE
					cut_overlays()
					add_overlay(image('icons/obj/storage.dmi', icon_opened))
					code = null
					e_code = ""

				else
					code = "ERROR"
					e_code = ""
			if("R")
				if(!emagged && !l_setshort)
					locked = TRUE
					cut_overlays()
					code = null
					e_code = ""
					close(usr)
			else
				if(length(code) >= 5)
					code = "ERROR"
					e_code = ""
				else
					code += "*"

					if(AUTHENTICATE(src, usr))
						e_code += l_code[length(e_code) + 1]
					else
						e_code += "[rand(0, 9)]"

		add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				attack_self(M)

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "secure-r"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_LARGE

/obj/item/weapon/storage/secure/briefcase/atom_init()
	. = ..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/briefcase/attack_hand(mob/user)
	if ((src.loc == user) && (src.locked == 1))
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((src.loc == user) && (!src.locked))
		src.open(usr)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
	src.add_fingerprint(user)

/obj/item/weapon/storage/secure/briefcase/attackby(obj/item/weapon/W, mob/user)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/Topic(href, href_list)
	..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/update_icon()
	if(!locked || emagged)
		item_state = "secure-g"
	else
		item_state = "secure-r"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/weapon/storage/secure/briefcase/syndie
	force = 15.0

/obj/item/weapon/storage/secure/briefcase/syndie/atom_init()
	for (var/i in 1 to 4)
		new /obj/item/weapon/spacecash/c1000(src)
	. = ..()


// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8.0
	w_class = 8.0
	max_w_class = 8
	anchored = 1.0
	density = 0
	cant_hold = list("/obj/item/weapon/storage/secure/briefcase")

/obj/item/weapon/storage/secure/safe/atom_init()
	. = ..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user)
	return attack_self(user)

//obj/item/weapon/storage/secure/safe/HoS/atom_init()
//	. = ..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)
