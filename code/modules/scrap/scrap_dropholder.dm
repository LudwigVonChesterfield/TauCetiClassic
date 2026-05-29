/obj/effect/falling_effect
	name = "you should not see this"
	desc = "no data"
	invisibility = 101
	anchored = TRUE
	density = FALSE

	var/fall_duration = 7
	var/show_shadow = FALSE

/obj/effect/falling_effect/atom_init(mapload, type, atom/movable/object, fall_duration, show_shadow=FALSE)
	..()

	if(!isnull(fall_duration))
		src.fall_duration = fall_duration

	if(!isnull(show_shadow))
		src.show_shadow = show_shadow

	if(object)
		object.loc = src
	else
		if(!type)
			type = /obj/random/scrap/moderate_weighted
		new type(src)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/falling_effect/atom_init_late()
	var/atom/movable/dropped = pick(src.contents) //stupid, but allows to get spawn result without efforts if it is other type
	dropped.loc = get_turf_loc(src)

	var/initial_x = dropped.pixel_x
	var/initial_y = dropped.pixel_y

	dropped.plane = ABOVE_GAME_PLANE
	dropped.pixel_x = rand(-150, 150)
	dropped.pixel_y = 500 //when you think that pixel_z is height but you are wrong
	dropped.density = FALSE
	dropped.opacity = 0

	if(show_shadow)
		var/matrix/shadow_transform = matrix(dropped.transform)
		shadow_transform.Scale(2.5, 2.5)

		var/matrix/end_shadow_transform = matrix(dropped.transform)
		end_shadow_transform.Scale(0.3, 0.3)

		var/image/shadow = new(dropped.icon, dropped.icon_state)
		shadow.appearance = dropped
		shadow.plane = GAME_PLANE
		shadow.layer = ABOVE_FLY_LAYER
		shadow.color = "#000000"
		shadow.transform = shadow_transform
		shadow.alpha = 100
		shadow.loc = dropped.loc

		shadow.pixel_x = rand(-3, 3)
		shadow.pixel_y = rand(-3, 3)

		flick_overlay_view(shadow, dropped.loc, fall_duration)

		animate(shadow, pixel_x = rand(-3, 3), pixel_y = rand(-3, 3), alpha = 200, transform=end_shadow_transform, time=fall_duration)
		QDEL_IN(shadow, fall_duration)

	animate(dropped, pixel_y = initial_y, pixel_x = initial_x , time = fall_duration)
	addtimer(CALLBACK(dropped, TYPE_PROC_REF(/atom/movable, end_fall)), fall_duration)

	qdel(src)

/atom/movable/proc/end_fall()
	for(var/atom/movable/AM in loc)
		if(AM != src)
			AM.ex_act(EXPLODE_DEVASTATE) // ouch
	for(var/mob/living/M in oviewers(6, src))
		shake_camera(M, 2, 2)
	play_end_fall_sound()
	density = initial(density)
	opacity = initial(opacity)
	plane = initial(plane)

/obj/structure/scrap/end_fall()
	. = ..()

	if(prob(66))
		return

	var/turf/src_turf = get_turf(src)

	// TO-DO: throw and activate stuff from inside the scrap pile instead? For instance activated
	// grenades would be hilarious.
	var/list/possible_shrapnel_targets = RANGE_TURFS(1, src_turf)
	var/turf/T = pick(possible_shrapnel_targets)

	var/static/list/shrapnel_types = list(
		/obj/item/weapon/scrap_lump = 34,
		/obj/item/weapon/shard = 33,
		/obj/item/stack/rods = 33,
	)

	for(var/i in 1 to rand(1, 3))
		var/shrapnel_type = pickweight(shrapnel_types)
		var/obj/item/I = new(shrapnel_type)
		I.throw_at(T, 1, I.throw_speed, thrower=null, spin=prob(50))

/atom/movable/proc/play_end_fall_sound()
	playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)

/obj/structure/scrap/play_end_fall_sound()
	playsound(src, 'sound/effects/scrap_fall.ogg', VOL_EFFECTS_MASTER)

/obj/effect/falling_effect/ex_act()
	return
