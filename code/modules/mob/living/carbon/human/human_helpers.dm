/mob/living/carbon/human/is_busy(atom/target, show_warning = TRUE)
	if(busy_with_action)
		if(!has_trait(TRAIT_MULTITASKING) || (busy_left_hand && busy_right_hand))
			if(show_warning)
				to_chat(src, "<span class='warning'>You are busy. Please finish or cancel your current action.</span>")
			return TRUE
	if(target && target.in_use_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>Please wait while someone else will finish interacting with [target].</span>")
		return TRUE
	return combo_animation || attack_animation

/mob/living/carbon/human/become_busy(atom/target, _hand = 0) // 0 is right hand, don't question it we don't have defines for this yet.
	if(_hand)
		busy_left_hand = TRUE
	else
		busy_right_hand = TRUE
	busy_with_action = TRUE

	if(target)
		target.in_use_action = TRUE

/mob/living/carbon/human/become_not_busy(atom/target, _hand = 0) // See remark above.
	if(_hand)
		busy_left_hand = FALSE
	else
		busy_right_hand = FALSE
	if(!busy_left_hand && !busy_right_hand)
		busy_with_action = FALSE

	if(target)
		target.in_use_action = FALSE
