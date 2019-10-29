/proc/get_rune_approx_color(color)
	if(global.color_to_approx_rune_color[color])
		return global.color_to_approx_rune_color[color]
	else
		var/list/col_rgb = ReadRGB(color)
		var/min_dist = 442 // sqrt(255^2 * 3)
		var/min_color = ""

		for(var/approx_col in global.spell_colors_to_use)
			var/dist = 0
			var/list/approx_col_rgb = ReadRGB(approx_col)
			for(var/i in 1 to col_rgb.len)
				dist += (approx_col_rgb[i] - col_rgb[i]) ^ 2
			dist = sqrt(dist)
			if(dist < min_dist)
				min_dist = dist
				min_color = approx_col

		global.color_to_approx_rune_color[color] = min_color
		return min_color
