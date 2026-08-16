class_name SkillTooltip
extends PanelContainer


func setup(
	skill_name: String,
	description: String,
	mana_cost: int,
	cooldown: float
) -> void:
	var name_label := get_node_or_null(
		"ContentMargin/Content/NameLabel"
	) as Label

	var description_label := get_node_or_null(
		"ContentMargin/Content/DescriptionLabel"
	) as Label

	var mana_label := get_node_or_null(
		"ContentMargin/Content/ManaLabel"
	) as Label

	var cooldown_label := get_node_or_null(
		"ContentMargin/Content/CooldownLabel"
	) as Label


	if name_label:
		name_label.text = skill_name


	if description_label:
		description_label.text = description


	if mana_label:
		mana_label.text = "Mana: %d" % mana_cost


	if cooldown_label:
		cooldown_label.text = (
			"Cooldown: %.1f s" % cooldown
		)
