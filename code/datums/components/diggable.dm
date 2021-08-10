#define DIGGABLE_TIP "Is diggable."

/datum/mechanic_tip/diggable
	tip_name = DIGGABLE_TIP
	description = "Can be dug with certain tools."


/datum/component/diggable
	var/dug = FALSE
	var/dug_grave = FALSE

	var/dug_icon_plating
	var/dug_icon_state

	var/resource_type

/datum/component/diggable/Initialize(dug_icon_plating, dug_icon_state, resource_type)
	if(!istype(parent, /turf/simulated/floor))
		return COMPONENT_INCOMPATIBLE

	src.dug_icon_plating = dug_icon_plating
	src.dug_icon_state = dug_icon_state
	src.resource_type = resource_type

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/on_attackby)
	RegisterSignal(parent, list(COMSIG_ATOM_EX_ACT), .proc/on_ex_act)
	RegisterSignal(parent, list(COMSIG_DIGGABLE_DUG), .proc/on_dig)

	var/datum/mechanic_tip/diggable/diggable_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(diggable_tip))

/datum/component/diggable/Destroy()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_EX_ACT))

	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(DIGGABLE_TIP))

	return ..()

/datum/component/diggable/proc/on_attackby(datum/source, obj/item/I, mob/living/user, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/try_dig, user, I)
	return NONE

/datum/component/diggable/proc/on_ex_act(datum/source, severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if(prob(70))
				gets_dug()
		if(1.0)
			gets_dug()

/datum/component/diggable/proc/on_dig(datum/source)
	gets_dug()
	return TRUE

/datum/component/diggable/proc/try_dig(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/weapon/shovel))
		return

	var/turf/T = user.loc
	if(!istype(T))
		return

	if(dug && dug_grave)
		to_chat(user, "<span class='danger'>This area has already been dug.</span>")
		return

	if(user.is_busy(T))
		return

	to_chat(user, "<span class='warning'>You start digging.</span>")
	if(!I.use_tool(T, user, 40, volume = 50))
		return

	to_chat(user, "<span class='notice'>You dug a hole.</span>")
	gets_dug(user)

/datum/component/diggable/proc/gets_dug(mob/living/user=null)
	if(dug && dug_grave)
		return

	var/turf/simulated/floor/T = parent

	if(dug)
		dug_grave = TRUE
		if(user)
			T.visible_message("<span class='notice'>\The [user] shovels a new grave.</span>")
		else
			T.visible_message("<span class='notice'>A new grave is shoveled at [T].</span>")
		new /obj/structure/pit(T)
		return

	for(var/i in 1 to 5)
		new resource_type(T)

	dug = TRUE
	T.icon_plating = dug_icon_plating
	T.icon_state = dug_icon_state
