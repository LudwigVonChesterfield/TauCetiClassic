/datum/component/remote_cursor
	var/list/mob/living/controllers
	var/mob/camera/cursor/cursor

	var/cursor_type
	var/image/cursor_image
	var/turf/default_position

	var/list/datum/action/actions

	// Used for parent->component interactions. Save a state of cursor here in any form.
	var/state

	// Used for more complex parent->component interactions, has action/palette_choice integration.
	var/list/data

	var/datum/callback/on_click

/datum/component/remote_cursor/Initialize(
	cursor_type,
	image/cursor_image,
	actions,
	default_position,
	default_state,
	datum/callback/on_click
)
	src.cursor_type = cursor_type
	src.cursor_image = cursor_image
	src.default_position = default_position
	src.state = default_state

	if(actions)
		src.actions = list()
		for(var/act_type in actions)
			var/datum/action/A = new act_type
			if(istype(A, /datum/action/collective/cursor))
				var/datum/action/collective/cursor/C = A
				C.remote = src
			src.actions += A

	src.on_click = on_click

/datum/component/remote_cursor/Destroy()
	for(var/C in controllers)
		revoke_control(C)
	controllers = null

	QDEL_LIST(actions)
	QDEL_NULL(cursor)
	return ..()

/datum/component/remote_cursor/proc/on_click(datum/source, atom/A, params)
	// to-do: on-click Callback binds?
	if(on_click)
		return on_click.Invoke(source, A, params)
	return COMPONENT_CANCEL_CLICK

/datum/component/remote_cursor/proc/on_logout(datum/source)
	revoke_actions(source)
	return NONE

/datum/component/remote_cursor/proc/grant_actions(mob/living/L)
	for(var/V in actions)
		var/datum/action/A = V
		A.Grant(L)

/datum/component/remote_cursor/proc/revoke_actions(mob/living/L)
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(L)

/datum/component/remote_cursor/proc/create_cursor()
	var/turf/T = default_position
	cursor = new cursor_type(null, src, cursor_image)
	if(!T)
		T = pick(get_area_turfs(cursor.allowed_area_type))
	cursor.loc = T

/datum/component/remote_cursor/proc/grant_control(mob/living/L)
	if(!controllers)
		data = list()

	if(!cursor)
		create_cursor()

	LAZYADD(controllers, L)

	L.remote_control = cursor
	L.reset_view(cursor)
	cursor.add_controller(L)

	grant_actions(L)

	L.force_remote_viewing = TRUE

	RegisterSignal(L, list(COMSIG_MOB_CLICK), .proc/on_click)

	RegisterSignal(L, list(COMSIG_MOB_LOGOUT), .proc/on_logout)

	LAZYADD(cursor.viewer_image.seers, L)
	cursor.viewer_image.add_hud_to(L)

/datum/component/remote_cursor/proc/revoke_control(mob/living/L)
	revoke_actions(L)

	if(L.client)
		L.reset_view(null)

	L.remote_control = null
	cursor.remove_controller(L)

	LAZYREMOVE(cursor.viewer_image.seers, L)
	cursor.viewer_image.remove_hud_from(L)

	L.force_remote_viewing = FALSE

	UnregisterSignal(L, list(COMSIG_MOB_CLICK, COMSIG_MOB_LOGOUT))

	LAZYREMOVE(controllers, L)
	if(!controllers)
		QDEL_NULL(cursor)
		data = null



/mob/camera/cursor
	name = "Inactive Camera Eye"

	var/list/controlled_by = list()

	var/datum/component/remote_cursor/remote

	var/datum/atom_hud/alternate_appearance/basic/list_people/viewer_image

	var/allowed_area_type
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = FALSE
	var/eye_initialized = FALSE

/mob/camera/cursor/atom_init(mapload, datum/component/remote_cursor/remote, image/cursor_image)
	. = ..()
	src.remote = remote

	if(cursor_image)
		var/image/I = image(cursor_image.icon, cursor_image.icon_state)
		I.appearance = cursor_image
		I.loc = src
		viewer_image = add_alt_appearance(
			/datum/atom_hud/alternate_appearance/basic/list_people,
			"cursor",
			I,
			list()
		)

/mob/camera/cursor/Destroy()
	remove_alt_appearance("cursor")

	for(var/L in controlled_by)
		remove_controller(L)

	remote = null
	return ..()

/mob/camera/cursor/proc/add_controller(mob/living/L)
	controlled_by += L
	RegisterSignal(L, list(COMSIG_PARENT_QDELETED), .proc/remove_controller)

/mob/camera/cursor/proc/remove_controller(mob/living/L)
	UnregisterSignal(L, list(COMSIG_PARENT_QDELETED))
	controlled_by -= L

/mob/camera/cursor/relaymove(mob/user,direct)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/movement = get_step(src, direct)
		if(movement)
			setLoc(movement)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/mob/camera/cursor/setLoc(turf/T)
	if(allowed_area_type != null && !istype(get_area(T), allowed_area_type))
		return FALSE

	T = get_turf(T)
	loc = T

	for(var/mob/living/L in controlled_by)
		if(!L.client)
			continue
		L.client.eye = src

	update_parallax_contents()
	return TRUE

// Movement code. Returns 0 to stop air movement from moving it.
/mob/camera/cursor/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	return FALSE

// Hide popout menu verbs
/mob/camera/cursor/examinate(atom/A as mob|obj|turf in view())
	set popup_menu = 0
	set src = usr.contents
	return 0

/mob/camera/cursor/pointed()
	set popup_menu = 0
	set src = usr.contents
	return 0



/datum/action/collective/cursor_off
	name = "End Cursor View"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "camera_off"
	action_type = AB_INNATE

/datum/action/collective/cursor_off/Activate(mob/living/user)
	var/mob/living/L = user
	var/mob/camera/cursor/C = L.remote_control
	C.remote.revoke_control(L)
