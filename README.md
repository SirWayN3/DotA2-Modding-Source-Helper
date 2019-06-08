# DotA2-Modding-Source-Helper


Check for AutoItV3 Online if you need Help.

IDE is ISN AutoIt Studio.


This Script will allow you do to the following:

- Split your Entity, Ability ect. Source Files into multiple ones. (Extension Has to be .cpp; Best use for Sublime anyway)
- Merge them all together into the according DotA2 used Files.
- Apply Additional Language Description Directly into those Source Files. Also able to access KeyValues through the Structure
- Merge Language Files into the according DotA2 Files.


Examples:

	"cf_01_ab_builder_bu01"
	{
		/*
			[self]
			target=Ability_Names_Builder
			type=ability
			name=Build $self.UnitName.this$
			descr=$self.UnitName.this$ trains $self.UnitName.Ability1.cf_unit_name.this$. Cheap meele Units.<br>Upgradable to Defender.<br><br>Gold Cost: $self.cf_AbilityGoldCost$
		*/
		"BaseClass"                     "ability_datadriven"
		"AbilityTextureName"			""
		
	}

Will Create the following:

	"DOTA_Tooltip_Ability_cf_01_ab_builder_bu01"			"Build Barracks"
	"DOTA_Tooltip_Ability_cf_01_ab_builder_bu01_Description"			"Barracks trains Footman. Cheap meele Units.<br>Upgradable to Defender.<br><br>Gold Cost: 100"
	"DOTA_Tooltip_Ability_cf_01_ab_builder_bu01_Lore"			""