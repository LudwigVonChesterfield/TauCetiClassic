/datum/action/collective
	var/list/users

/datum/action/collective/Destroy()
	if(users)
		var/list/L = list() + users
		for(var/mob/M in L)
			Remove(M)
	return ..()

/datum/action/collective/Grant(mob/living/T)
	..()
	LAZYADD(users, T)

/datum/action/collective/Remove(mob/living/T)
	LAZYREMOVE(users, T)
	..()



// Toggleable prolonged cursor actions.
/datum/action/collective/cursor
	// What cursor state does this action require
	var/require_state
	// What cursor state should the object acquire upon activating this action
	var/action_state

	var/datum/component/remote_cursor/remote

/datum/action/collective/cursor/Destroy()
	if(remote.state == action_state)
		stop_action()
		remote.state = require_state

	return ..()

/datum/action/collective/cursor/Remove(mob/living/T)
	if(remote.state == action_state)
		stop_action()
		remote.state = require_state

	return ..()

/datum/action/collective/cursor/Activate(mob/living/user)
	if(remote.state == require_state)
		if(start_action(user))
			remote.state = action_state
	else if(remote.state == action_state)
		if(stop_action(user))
			remote.state = require_state

// Return FALSE if an action could not be started, and thus change of state is not required.
/datum/action/collective/cursor/proc/start_action(mob/living/user)
	return TRUE

// Return FALSE if an action could not be stopped, and thus change of state is not required.
/datum/action/collective/cursor/proc/stop_action(mob/living/user)
	return TRUE
