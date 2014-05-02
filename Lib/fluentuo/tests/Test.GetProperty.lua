TestGetProperty = {}
	local TestPropertyName = "A Test Item"
	local TestPropertyWeight = 15
	local TestPropertyHitManaLeech = 5
	local TestPropertyPoisonResist = 15
	local TestPropertyWeaponSpeed = 56
	local TestPropertyWeaponDamage = {Min = 10, Max = 11}
	local TestPropertyWeaponSkillRequired = "Fencing"
	local TestPropertyCharges = {Min = 5, Max = 25}
	local TestPropertyString = "Weight: "..TestPropertyWeight.." stones\nTwo-Handed Weapon\nCharges: "..TestPropertyCharges.Min.." / "..TestPropertyCharges.Max.."\nHit Mana Leech "..TestPropertyHitManaLeech.."%\nPoison Resist "..TestPropertyPoisonResist.."%\nWeapon Speed "..TestPropertyWeaponSpeed.."\nWeapon Damage "..TestPropertyWeaponDamage.Min.." - "..TestPropertyWeaponDamage.Max.."\nSkill Required: "..TestPropertyWeaponSkillRequired
	local TestPropertyItem = {ID = 24}

	local function CreatePropertyItem()
		UO.Property(TestPropertyItem.ID)		;Mock:returns(TestPropertyName,TestPropertyString)
	end

	function TestGetProperty:setUp()
		MockUO()
		math.randomseed( os.time() )
		CreatePropertyItem()
	end

	local function LoadProperties()
		Mock:replay()
		local props = FluentUO.GetProperty(TestPropertyItem)
		Mock:verify()
		return props
	end

	function TestGetProperty:test_lookup_exact_properties_by_name()
		local props = LoadProperties()

		assertEquals(props["Name"],TestPropertyName)
		assertEquals(props["Weight"],TestPropertyWeight)
		assertEquals(props["Hit Mana Leech"],TestPropertyHitManaLeech)
		assertEquals(props["Poison Resist"],TestPropertyPoisonResist)
		assertEquals(props["Weapon Speed"],TestPropertyWeaponSpeed)
		assertEquals(props["Weapon Damage"].Min,TestPropertyWeaponDamage.Min)
		assertEquals(props["Weapon Damage"].Max,TestPropertyWeaponDamage.Max)
		assertEquals(props["Skill Required"],TestPropertyWeaponSkillRequired)
		assertEquals(props["Charges"].Min,TestPropertyCharges.Min)
		assertEquals(props["Charges"].Max,TestPropertyCharges.Max)
		assertEquals(props["Two-Handed Weapon"],true)
	end

	function TestGetProperty:test_lookup_resists_by_resists_table()
		local props = LoadProperties()

		assertEquals(props.Resists.Poison,TestPropertyPoisonResist)
	end

	function TestGetProperty:test_lookup_exact_properties_by_table()
		local props = LoadProperties()

		assertEquals(props.Name,TestPropertyName)
		assertEquals(props.Weight,TestPropertyWeight)
		assertEquals(props.Charges.Min,TestPropertyCharges.Min)
	end

	function TestGetProperty:test_lookup_exact_properties_by_metatable()
		local props = LoadProperties()

		assertEquals(props.HitManaLeech,TestPropertyHitManaLeech)
		assertEquals(props.PoisonResist,TestPropertyPoisonResist)
		assertEquals(props.weapondamage.Max,TestPropertyWeaponDamage.Max)
		assertEquals(props.skillrequired,TestPropertyWeaponSkillRequired)
	end

	function TestGetProperty:test_lookup_exact_properties_by_metatable_with_case_insensitivity()
		local props = LoadProperties()

		assertEquals(props["hit mana leech"],TestPropertyHitManaLeech)
	end
