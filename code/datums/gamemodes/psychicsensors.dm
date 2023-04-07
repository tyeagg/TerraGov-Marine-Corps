#define SENSORS_NEEDED_PSY 5

/datum/game_mode/psy_sensors
	name = "Psychic Sensors"
	config_tag = "Psychic Sensors"
	flags_round_type = MODE_INFESTATION|MODE_LATE_OPENING_SHUTTER_TIMER|MODE_HUMAN_ONLY|MODE_DEAD_GRAB_FORBIDDEN
	flags_xeno_abilities = ABILITY_CRASH
	shutters_drop_time = 3 MINUTES
	valid_job_types = list(
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
	)
	whitelist_ship_maps = list(MAP_ARROW_OF_ARTEMIS)
	blacklist_ship_maps = null
	blacklist_ground_maps = null
	whitelist_ground_maps = list(MAP_PATRICKS_REST)
	/// Timer used to calculate how long till round ends
	var/game_timer
	///The length of time until round ends.
	var/max_game_time = 15 MINUTES
	/// Timer used to calculate how long till next respawn wave
	var/wave_timer
	///The length of time until next respawn wave.
	var/wave_timer_length = 4 MINUTES
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	///The amount of activated psychic inhibitors
	var/sensors_activated = 0

/datum/game_mode/psy_sensors/post_setup()
	. = ..()
	for(var/turf/T AS in GLOB.psy_towers)
		new /obj/structure/sensor_tower_patrol/psy(T)
	for(var/turf/T AS in GLOB.spawner_cave_drone)
		new /obj/structure/spawner_cave(T)
	for(var/turf/T AS in GLOB.spawner_cave_runner)
		new /obj/structure/spawner_cave/runner(T)
	for(var/turf/T AS in GLOB.spawner_cave_sentinel)
		new /obj/structure/spawner_cave/sentinel(T)

/datum/game_mode/psy_sensors/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 5 //For every 5 marine late joins, 1 extra SG

/datum/game_mode/psy_sensors/setup_blockers()
	. = ..()
	//Starts the round timer when the game starts proper
	var/datum/game_mode/psy_sensors/D = SSticker.mode
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/psy_sensors, set_game_timer)), SSticker.round_start_time + shutters_drop_time)
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/psy_sensors, respawn_wave)), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/psy_sensors, intro_sequence)), SSticker.round_start_time + shutters_drop_time - 50 SECONDS) //starts intro sequence 10 seconds before shutter drop

/datum/game_mode/psy_sensors/announce()
	to_chat(world, "<b>The current game mode is - Psychic Sensors!</b>")
	to_chat(world, "<b>Xeno</b>")

///plays the intro sequence
/datum/game_mode/psy_sensors/proc/intro_sequence()
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)

/datum/game_mode/psy_sensors/proc/respawn_wave()
	var/datum/game_mode/psy_sensors/D = SSticker.mode
	D.wave_timer = addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/psy_sensors, respawn_wave)), wave_timer_length, TIMER_STOPPABLE)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] -= respawn_time
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>RESPAWN WAVE AVAILABLE</u></span><br>" + "YOU CAN NOW RESPAWN.", /atom/movable/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join a fresh patrol!")]</font><br>")

///round timer
/datum/game_mode/psy_sensors/proc/set_game_timer()
	if(!ispsysensorgamemode(SSticker.mode))
		return
	var/datum/game_mode/psy_sensors/D = SSticker.mode

	if(D.game_timer)
		return

	D.game_timer = addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/psy_sensors, set_game_end)), max_game_time, TIMER_STOPPABLE)

/datum/game_mode/psy_sensors/game_end_countdown()
	if(!game_timer)
		return
	var/eta = timeleft(game_timer) * 0.1
	if(game_timer == SENSOR_CAP_TIMER_PAUSED)
		return "Timer paused, tower activation in progress"
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"
	else
		return "Patrol finished"

/datum/game_mode/psy_sensors/wave_countdown()
	if(!wave_timer)
		return
	var/eta = timeleft(wave_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

/datum/game_mode/psy_sensors/proc/set_game_end()
	max_time_reached = TRUE

//End game checks
/datum/game_mode/psy_sensors/check_finished()
	if(round_finished)
		return TRUE

	if(max_time_reached)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE

	if(sensors_activated >= SENSORS_NEEDED_PSY)
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]")
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
