class_name AISpawnSystem
extends RefCounted

func choose_unit(units: Array[UnitDefinition], mana: float) -> UnitDefinition:
	var affordable: Array[UnitDefinition] = []
	for unit in units:
		if unit.cost <= mana:
			affordable.append(unit)
	if affordable.is_empty() or randf() > 0.72:
		return null
	var total := 0.0
	for unit in affordable:
		total += 3.0 if unit.cost <= 4 else 1.0
	var roll := randf() * total
	for unit in affordable:
		var weight := 3.0 if unit.cost <= 4 else 1.0
		if roll < weight:
			return unit
		roll -= weight
	return affordable[0]
