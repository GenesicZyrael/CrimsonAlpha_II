# CrimsonAlpha_II
back-up repo incase things goes south.

Put this in your user_configs. Please take note of the load order of the repos. This one requires the Project Ignis core, so it must be listed first before CrimsonAlpha_II is loaded. 


{
	"repos": [
		{
			"url": "https://github.com/ProjectIgnis/DeltaBagooska",
			"repo_name": "Project Ignis updates",
			"repo_path": "./repositories/delta-bagooska",
			"has_core": true,
			"core_path": "bin",
			"data_path": "",
			"script_path": "script",
			"should_update": true,
			"should_read": true
		},
		{
			"url": "https://github.com/GenesicZyrael/CrimsonAlpha_II",
			"repo_name": "Crimson Alpha updates",
			"repo_path": "./repositories/CrimsonAlpha_II",
			"has_core": true,
			"core_path": "bin",
			"data_path": "",
			"script_path": "script",
			"should_update": true,
			"should_read": true
		}
	]
}

