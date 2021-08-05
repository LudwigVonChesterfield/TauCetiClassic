/obj/item/weapon/paper/diy_station_pamphlet
	name = "introductory pamphlet"
	icon_state = "pamphlet"
	info = "<b>Добро пожаловать на станцию проекта \"Собери Свою Станцию Сам\"</b><br>\
			Поздравляем! Если вы это читаете, ваше начальство решило, что вы готовы \
			начать жизнь осваивания целины далёких миров, вы будете колонизаторами, первопроходцами. \
			Вам нужно быть готовым к приключениям, суровым испытаниям, и лучшему \
			соц. пакету что мы можем предоставить - но даже это не всё, что вас ждёт на нашем проекте.<br><br>\
			Так как мы беспокоимся о вас, мы считаем что вам необходимо знать о всех рисках, \
			перед тем как вы приступите к работе. Астероид \"Москва\" был полностью изучен \
			экспедиционной командой НаноТрейзен, и точно совсем гарантировано безопасен на все 100%. \
			Вы были снабжены базовым необходимым снаряжением для расширения базы операций и начала жизни с \
			чистого листа.<br><br>\
			<b>Первым Делом</b><br>\
			Прибыв на астероид \"Москва\" вы обнаружите себя на аванпосте \"Красная Площадь\". Аванпост снабжён \
			необходимыми ресурсами для корректной работы лишь первых пол часа по прибытию экипажа. В связи \
			с этим вашим первым приоритетом будет обеспечить корректную работу аванпоста. Для этого \
			будет необходимо:<br>\
			- Настроить источник питания.<br>\
			- Гарантировать наличие скафандров у каждого члена экипажа.<br>\
			- Наладить производство еды, медикаментов.<br><br>\
			<b>О Чудный, Новый Мир</b><br>\
			Как участник проекта, вы будете направлены на самые далёкие просторы космоса. И даже при том, \
			что ваша полная безопасность гарантирована, участникам рекомендуется готовиться к крайне \
			негостепреимной, агрессивной окружающей среде. Будьте осторожны."

//we don't want the silly text overlay!
/obj/item/weapon/paper/diy_station_pamphlet/update_icon()
	return



/obj/item/weapon/paper/personal_tasks
	name = "Личные Задания Члена Экипажа"

/obj/item/weapon/paper/personal_tasks/proc/gen_info(mob/living/carbon/human/H)
	name = "Личные Задания Члена Экипажа ([H.name])"
	info = get_personal_tasks(H)

	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "NanoTrasen Expedition Department")

	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/personal_tasks/proc/get_personal_tasks(mob/living/carbon/human/H)
	var/paper_text = "<center><img src = bluentlogo.png /><br /><font size = 3><b>[H.name]</b> Личные Задания:</font></center><br /><hr>"
	// paper_text += "Scan results show the following points of interest:<br />"

	var/task_amount = 5

	var/list/tasks = list()

	for(var/i in 1 to task_amount)
		var/task
		for(var/j in 1 to 5)
			task = get_task()
			if(task in tasks)
				continue
			break

		tasks += task
		paper_text += "<li><b>*</b> [task] \[<span class=\"paper_field\"></span>\]</li>"
		fields++

	return paper_text

/obj/item/weapon/paper/personal_tasks/proc/get_task()
	return pickweight(list(
		"Построить [get_room_name()]." = 10,
		"Настроить [get_appliance_name()]." = 1,
		//"Добыть [get_resource_name()]." = 1,
	))

/obj/item/weapon/paper/personal_tasks/proc/get_room_name()
	var/list/pos_rooms = list("баню", "казино", "коммунизм", "путь к докам", "доки", "мавзолей")
	for(var/area_type in subtypesof(/area/station) - subtypesof(/area/station/maintenance))
		if(area_type in areas_by_type)
			continue
		var/area/A = area_type
		pos_rooms += lowertext(initial(A.name))

	return pick(pos_rooms)

/obj/item/weapon/paper/personal_tasks/proc/get_appliance_name()
	var/list/pos_appliance = list(
		"исскуственный интеллект",
		"генератор",
		"систему жизнеобеспечения",
		"атмосферный отсек"
	)
	return pick(pos_appliance)

// /obj/item/weapon/paper/personal_tasks/proc/get_resource_name()

/obj/item/comrade_package
	desc = "A small wrapped package, just for you. Comrade."
	name = "small red parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "theredcrate"

	w_class = ITEM_SIZE_TINY

/obj/item/comrade_package/attack_self(mob/user)
	user.drop_from_inventory(src, null)

	var/obj/item/weapon/folder/red/R = new()

	new /obj/item/weapon/paper/diy_station_pamphlet(R)

	var/obj/item/weapon/paper/personal_tasks/PT = new(R)
	PT.gen_info(user)

	user.put_in_hands(R)
	qdel(src)
