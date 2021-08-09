/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/atom_init()
	. = ..()
	find_computer()
	AddComponent(/datum/component/clickplace)

/obj/machinery/optable/Destroy()
	computer = null
	victim = null
	return ..()

/obj/machinery/optable/proc/find_computer()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = FALSE
		else
	return

/obj/machinery/optable/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/optable/attack_paw(mob/user)
	if ((HULK in usr.mutations))
		user.SetNextMove(CLICK_CD_MELEE)
		to_chat(usr, text("<span class='notice'>You destroy the operating table.</span>"))
		visible_message("<span class='danger'>[usr] destroys the operating table!</span>")
		src.density = FALSE
		qdel(src)
	return

/obj/machinery/optable/attack_hand(mob/user)
	if (HULK in usr.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		to_chat(usr, text("<span class='notice'>You destroy the table.</span>"))
		visible_message("<span class='danger'>[usr] destroys the operating table!</span>")
		src.density = FALSE
		qdel(src)
	else
		return ..() // for fun, for braindamage and fingerprints.

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(atom/A, mob/user)
	if(user.incapacitated())
		return
	if (iscarbon(A) && isturf(user.loc) && user.IsAdvancedToolUser())
		var/mob/living/carbon/M = A
		if (M.buckled)
			M.buckled.user_unbuckle_mob(user)
		take_victim(M, user)
		return
	return ..()

/obj/machinery/optable/proc/check_victim()
	var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
	if(M && M.resting)
		victim = M
		icon_state = M.pulse ? "table2-active" : "table2-idle"
		return TRUE

	victim = null
	icon_state = "table2-idle"
	return FALSE

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	if (C == user)
		user.visible_message("<span class='rose'>[user] climbs on [src].</span>","<span class='notice'>You climb on [src].</span>")
	else
		visible_message("<span class='notice'>[C] has been laid on [src] by [user].</span>")
	if (C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src
	C.resting = 1
	C.loc = src.loc
	for(var/obj/O in src)
		O.loc = src.loc
	add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		src.victim = H
		icon_state = H.pulse ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || !ishuman(usr) || !usr.canmove)
		return

	if(src.victim)
		to_chat(usr, "<span class='rose'>The table is already occupied!</span>")
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/weapon/W, mob/living/carbon/user)
	if(isrobot(user))
		return

	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(iscarbon(G.affecting))
			take_victim(G.affecting, usr)
			user.SetNextMove(CLICK_CD_MELEE)
			qdel(G)
			return

	if(default_unfasten_wrench(user, W))
		if(anchored)
			find_computer()
		else
			computer = null
			victim = null
		return

	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0, user))
			user.visible_message("[user] begins unwelding [src]'s shutters with [WT].",
			                     "<span class='notice'>You begin to remove welding from [src]'s shutters with [WT]...</span>")
			if(WT.use_tool(src, user, 30, volume = 100))
				user.visible_message("[user] unwelds [src]'s shutters with [WT].",
				                     "<span class='notice'>You remove welding from [src]'s shutters with [WT].</span>")
				var/obj/item/stack/sheet/plasteel/P = new(loc)
				P.amount = 10
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return

	return ..()
