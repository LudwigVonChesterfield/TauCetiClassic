/proc/targetzone2hitzone(targetzone)
	switch(targetzone)
		if(BP_HEAD, O_MOUTH, O_MOUTH)
			return HITZONE_UPPER
		if(BP_CHEST, BP_L_ARM, BP_R_ARM)
			return HITZONE_MIDDLE
		if(BP_GROIN, BP_L_LEG, BP_R_LEG)
			return HITZONE_LOWER
