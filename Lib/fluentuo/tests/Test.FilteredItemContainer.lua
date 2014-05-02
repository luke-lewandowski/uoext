TestFilteredItemContainer = {}
	function TestFilteredItemContainer:setUp()
		MockUO()
		math.randomseed( os.time() )
	end

	---------------------------------------------------------------------------
	-- Sets up a table of items and mocks the calls for retrieving them. Will
	-- ensure that IDs are unique.
	-- @param iteminput a table of items to start with.
	-- @param nrandom the number of random items to generate. 10 by default.
	-- @return The table of items.
	function setUpItemTableVisibilityDefined(iteminput,nrandom,visibility)
		local items = iteminput
		if items == nil or nrandom ~= nil then
			items, nrandom = items or {}, nrandom or 11
			for i=1,nrandom do table.insert(items,randomItem()) end
		end

		local visibleitems, uniqueIDs = {}, {}
		for i=1,#items do
			if items[i].Visible then table.insert(visibleitems,items[i]) end
			while uniqueIDs[items[i].ID] ~= nil do
				items[i].ID = math.random(0,1000000)
			end
			uniqueIDs[items[i].ID] = items[i]
		end

		local X = UO.CharPosX		;Mock:returns(0):anytimes()
		local Y = UO.CharPosY		;Mock:returns(0):anytimes()

		if visibility then
			UO.ScanItems(true)			;Mock:returns(#visibleitems)
			for i=1,#visibleitems do
				UO.GetItem(i-1)			;Mock:returns(visibleitems[i].ID,visibleitems[i].Type,visibleitems[i].Kind,visibleitems[i].ContID,visibleitems[i].X,visibleitems[i].Y,visibleitems[i].Z,visibleitems[i].Stack,visibleitems[i].Rep,visibleitems[i].Col)
			end
		end

		Mock:close('GetItem')

		UO.ScanItems(false)			;Mock:returns(#items)
		for i=1,#items do
			UO.GetItem(i-1)			;Mock:returns(items[i].ID,items[i].Type,items[i].Kind,items[i].ContID,items[i].X,items[i].Y,items[i].Z,items[i].Stack,items[i].Rep,items[i].Col)
		end
		
		Mock:close('GetItem')

		Mock:close('CharPosX')
		Mock:close('CharPosY')

		return items
	end

	function setUpItemTable(iteminput,nrandom)
		return setUpItemTableVisibilityDefined(iteminput,nrandom,true)
	end

-------------------------------------------------------------------------------

	function TestFilteredItemContainer:test_no_filters()
		local itemtable = setUpItemTable()

		Mock:replay()

		local filtereditems = FluentUO.FilteredItemContainer().Items

		table.foreach(itemtable,function(i,v) assertEquals(filtereditems[i].ID,itemtable[i].ID) end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_visible_filter()
		local itemtable = setUpItemTable()
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Visible end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Visible().Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Visible,true) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_not_filter_with_visibility()
		local itemtable = setUpItemTable()
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Visible == false end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Not().Visible().Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Visible,false) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_not_filter_quadruple_negative_with_visibility()
		local itemtable = setUpItemTable()
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Visible end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Not().Not().Not().Not().Visible().Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Visible,true) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end
	
	function TestFilteredItemContainer:test_single_instance_different_filters()
		local ingotsEUO, otherEUO = "ENK", "TJG"
		local ingotsDEC, otherDEC = FluentUO.Utils.ToOpenEUO(ingotsEUO), FluentUO.Utils.ToOpenEUO(otherEUO)
		local items = {randomItem({Type = ingotsDEC}),randomItem({Type = ingotsDEC}),randomItem({Type = otherDEC})}
		local itemtable = setUpItemTable(items,10)
		local ingotsexpected = table.countintablewhere(itemtable,function(v) return v.Type == ingotsDEC end)
		local otherexpected = table.countintablewhere(itemtable,function(v) return v.Type == otherDEC end)
		
		Mock:replay()
		local filter = FluentUO.FilteredItemContainer()
		
		local ingots = filter.WithType(ingotsDEC).Items
		local others = filter.WithType(otherDEC).Items
		
		assertEquals(#ingots,ingotsexpected)
		assertEquals(#others,otherexpected)
		
		Mock:verify()		
	end
	
	
	
	function TestFilteredItemContainer:test_update_to_check_for_new_items()
		local ingotsEUO, otherEUO = "ENK", "TJG"
		local ingotsDEC, otherDEC = FluentUO.Utils.ToOpenEUO(ingotsEUO), FluentUO.Utils.ToOpenEUO(otherEUO)
		local items = {randomItem({Type = ingotsDEC}),randomItem({Type = ingotsDEC}),randomItem({Type = otherDEC})}
		local itemtable = setUpItemTable(items,10)
		local ingotsexpected = table.countintablewhere(itemtable,function(v) return v.Type == ingotsDEC end)
		local otherexpected = table.countintablewhere(itemtable,function(v) return v.Type == otherDEC end)
		local items2 = {randomItem({Type = ingotsDEC}),randomItem({Type = ingotsDEC}),randomItem({Type = ingotsDEC}),randomItem({Type = ingotsDEC})}
		local itemtable2 = setUpItemTable(items2,10)
		local newingotsexpected = table.countintablewhere(itemtable2,function(v) return v.Type == ingotsDEC end)
		local newotherexpected = table.countintablewhere(itemtable2,function(v) return v.Type == otherDEC end)
		
		Mock:replay()
		local filter = FluentUO.FilteredItemContainer()
		
		local ingots = filter.WithType(ingotsDEC).Items
		local others = filter.WithType(otherDEC).Items
		
		filter.Update()
		
		local newingots = filter.WithType(ingotsDEC).Items
		local newothers = filter.WithType(otherDEC).Items
		
		assertEquals(#ingots,ingotsexpected)
		assertEquals(#others,otherexpected)
		assertEquals(#newingots,newingotsexpected)
		assertEquals(#newothers,newotherexpected)
		assertEquals(ingotsexpected == newingotsexpected, false)
		assertEquals(otherexpected == newotherexpected, false)
		
		Mock:verify()		
		
	end



	function TestFilteredItemContainer:test_not_filter_to_exclude_by_multiple_ids()
		local itemtable = setUpItemTable()
		local IDtoFind1, IDtoFind2 = itemtable[3].ID, itemtable[4].ID
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ID ~= IDtoFind1 and v.ID ~= IDtoFind2 end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Not().WithID(IDtoFind1,IDtoFind2).Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_id_filter()
		local itemtable = setUpItemTable()
		local IDtoFind = itemtable[4].ID
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ID == IDtoFind end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithID(IDtoFind).Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.ID,IDtoFind) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_id_filter_using_a_string_as_the_id_parameter()
		local someonescharidEUO = "SDFJCSK"
		local someonescharidDEC = FluentUO.Utils.ToOpenEUO(someonescharidEUO)
		local items = {randomItem({ID = someonescharidDEC})}
		local itemtable = setUpItemTable(items,10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ID == someonescharidDEC end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithID(someonescharidEUO).Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.ID,someonescharidDEC) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_type_filter_using_a_string_as_the_type_parameter()
		local ingotsEUO = "ENK"
		local ingotsDEC = FluentUO.Utils.ToOpenEUO(ingotsEUO)
		local items = {randomItem({Type = ingotsDEC})}
		local itemtable = setUpItemTable(items,10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Type == ingotsDEC end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithType(ingotsEUO).Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Type,ingotsDEC) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_type_filter_using_a_delimited_string_with_frivolous_delimiters_as_the_type_parameter()
		local ingotsEUO, otherEUO = "ENK", "TJG"
		local ingotsDEC, otherDEC = FluentUO.Utils.ToOpenEUO(ingotsEUO), FluentUO.Utils.ToOpenEUO(otherEUO)
		local items = {randomItem({Type = ingotsDEC}),randomItem({Type = otherDec})}
		local itemtable = setUpItemTable(items,10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Type == ingotsDEC or v.Type == otherDEC end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithType("__"..ingotsEUO.."____"..otherEUO).Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_type_filter()
		local itemtable = setUpItemTable()
		local TypetoFind = itemtable[3].Type
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Type == TypetoFind end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithType(TypetoFind).Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Type,TypetoFind) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_color_filter()
		local itemtable = setUpItemTable()
		local ColToFind = itemtable[3].Col
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Col == ColToFind end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithHue(ColToFind).Items

		table.foreach(filteredItems, function(i,v) assertEquals(v.Col,ColToFind) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	local function setup_for_where_filter()
		return {
			randomItem({Kind == 1, Type = 2}),
			randomItem({Kind == 1, Type = 2}),
			randomItem({Kind == 1, Type = 3})
		}
	end



	function TestFilteredItemContainer:test_where_filter_with_function_callback_applied()
		local itemtable = setUpItemTable(setup_for_where_filter(),10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Kind == 1 and ( v.Type == 2 or v.Type == 3 ) end)
		local callback = function(item) return item.Kind == 1 and ( item.Type == 2 or item.Type == 3 ) end

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Where(callback).Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_where_filter_with_a_string_applied()
		local itemtable = setUpItemTable(setup_for_where_filter(),10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Kind == 1 and ( v.Type == 2 or v.Type == 3 ) end)
		local callbackstring = "item.Kind == 1 and ( item.Type == 2 or item.Type == 3 )"

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Where(callbackstring).Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_on_ground_filter()
		local itemtable = setUpItemTable()
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Kind == 1 end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().OnGround().Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_in_any_container_filter()
		local itemtable = setUpItemTable()
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Kind == 0 end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().InAnyContainer().Items

		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_chaining_of_filters()
		local item = randomItem({Type = 1234, Col = 2032, Visible = false, Kind = 0})
		local itemtable = setUpItemTable({item},10)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.Type == item.Type and v.Col == item.Col and v.Visible == item.Visible and v.Kind == item.Kind end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithType(1234).WithHue(2032).InAnyContainer().Not().Visible().Items
		assertEquals(#filteredItems,countexpected)
		table.foreach(filteredItems, function(i,v) assertEquals(v.Col,item.Col) assertEquals(v.Type,item.Type) assertEquals(v.Visible,item.Visible) assertEquals(v.Kind,item.Kind) end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_id_filter_with_multiple_ids()
		local itemtable = setUpItemTable()
		local IDtoFind1, IDtoFind2 = itemtable[3].ID, itemtable[4].ID
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ID == IDtoFind1 or v.ID == IDtoFind2 end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithID(IDtoFind1,IDtoFind2).Items
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	local function container_test_setup(c,nc)
		local contained, notcontained = c or math.random(2,5), nc or math.random(6,10)
		local container = randomItem()
		local items = {container}
		for i=1,contained do table.insert(items,randomItem({ContID = container.ID,Kind=0})) end
		for i=1,notcontained do table.insert(items,randomItem({ContID = container.ID + 1,Kind=0})) end
		return items,container,contained,notcontained
	end



	function TestFilteredItemContainer:test_in_container_filter()
		local items, container, contained = container_test_setup()
		setUpItemTable(items)
		Mock:replay()
		local filteredItems = FluentUO.FilteredItemContainer().InContainer(container.ID).Items
		assertEquals(#filteredItems,contained)
		Mock:verify()
	end



	function TestFilteredItemContainer:test_in_container_type_filter()
		local items, container, contained = container_test_setup()
		setUpItemTable(items)
		Mock:replay()
		local filteredItems = FluentUO.FilteredItemContainer().InContainerType(container.Type).Items
		assertEquals(#filteredItems,contained)
		Mock:verify()
	end



	function TestFilteredItemContainer:test_update_after_item_collection_has_changed()
		local itemtable = setUpItemTable()
		local IDtoFind, TypetoFind = itemtable[4].ID, itemtable[4].Type
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ID == IDtoFind and v.Type == TypetoFind end)

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer().WithID(IDtoFind).WithType(TypetoFind)
		local filteredItems = filter.Items
		table.foreach(filteredItems, function(i,v) assertEquals(v.Type,TypetoFind) assertEquals(v.ID,IDtoFind) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
		MockUO()

		itemtable = setUpItemTable({randomItem({ID = IDtoFind, Type = TypetoFind})},20)
		countexpected = table.countintablewhere(itemtable,function(v) return v.ID == IDtoFind and v.Type == TypetoFind end)

		Mock:replay()

		filter = filter.Update()
		filteredItems = filter.Items
		table.foreach(filteredItems, function(i,v) assertEquals(v.Type,TypetoFind) assertEquals(v.ID,IDtoFind) end)
		assertEquals(#filteredItems,countexpected)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_in_backpack_filter()
		local backpack = randomItem()
		local items = {backpack}
		for i=1,10 do items[#items+1] = randomItem({ContID = backpack.ID,Kind=0}) end
		local itemtable = setUpItemTable(items,30)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ContID == backpack.ID end)

		local temp = UO.BackpackID	;Mock:returns(backpack.ID):anytimes()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().InBackpack().Items

		assertEquals(#filteredItems,countexpected)
		table.foreach(filteredItems, function(i,v) assertEquals(v.ContID,backpack.ID) end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_equipped_filter()
		local char = randomItem()
		local items = {char}
		for i=1,10 do items[#items+1] = randomItem({ContID = char.ID,Kind=0}) end
		local itemtable = setUpItemTable(items)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ContID == char.ID end)

		local temp = UO.CharID	;Mock:returns(char.ID):anytimes()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().Equipped().Items

		assertEquals(#filteredItems,countexpected)
		table.foreach(filteredItems, function(i,v) assertEquals(v.ContID,char.ID) end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_parent_property_on_item()
		local parent = randomItem()
		local items = {parent}
		for i=1,10 do items[#items+1] = randomItem({ContID = parent.ID,Kind = 0}) end
		local itemtable = setUpItemTable(items)
		local countexpected = table.countintablewhere(itemtable,function(v) return v.ContID == parent.ID end)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().InContainer(parent.ID).Items

		assertEquals(#filteredItems,countexpected)
		table.foreach(filteredItems, function(i,v)
			assert(v.Parent ~= nil,"Item parent not set")
			assertEquals(v.Parent.ID,parent.ID)
		end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_rootparent_property_on_item()
		local parent = randomItem({ID = 1,Kind = 1})
		local items = {parent}
		for i=1,10 do items[#items+1] = randomItem({ID = i+1, ContID = items[#items].ID,Kind = 0}) end
		local child = items[#items]
		local itemtable = setUpItemTable(items)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().WithID(child.ID).Items

		assertEquals(#filteredItems,1)
		table.foreach(filteredItems, function(i,v)
			assert(v.RootParent ~= nil,"Item root parent not set")
			assertEquals(v.RootParent.ID,parent.ID)
		end)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_in_container_filter_with_recursion()
		local parent = randomItem({Kind = 1})
		local child1 = randomItem({ContID = parent.ID,Kind = 0})
		local items = {parent,child1}
		local numberofchildren = 10
		for i=1,numberofchildren do items[#items+1] = randomItem({ID = i+1, ContID = items[#items].ID,Kind = 0}) end
		local childlast = items[#items]
		local itemtable = setUpItemTable(items,0)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().InContainer(child1.ID,true).Items

		assertEquals(#filteredItems,numberofchildren)

		Mock:verify()
	end



	function TestFilteredItemContainer:test_in_range_filter()
		local items = {}
		local numberinrange = 10
		local maxrange = 3;
		for i=1,numberinrange do items[#items+1] = randomItem({X = math.random(1,maxrange), Y = math.random(1,maxrange)}) end
		for i=1,30 do items[#items+1] = randomItem({X = math.random(4,10), Y = math.random(4,10)}) end
		local itemtable = setUpItemTable(items,0)
		rawset(UO,"CharPosX",0)
		rawset(UO,"CharPosY",0)

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer().InRange(maxrange).Items

		assertEquals(#filteredItems,numberinrange)
		table.foreach(filteredItems, function(i,v) assert(v.Dist <= maxrange) end)

		Mock:verify()

	end



	local TestPropertyName = "A Test Item"
	local TestPropertyWeight = 15
	local TestPropertyHitManaLeech = 5
	local TestPropertyPoisonResist = 15
	local TestPropertyWeaponSpeed = 56
	local TestPropertyWeaponDamage = {Min = 10, Max = 11}
	local TestPropertyWeaponSkillRequired = "Fencing"
	local TestPropertyCharges = {Min = 5, Max = 25}
	local TestPropertyString = "Weight: "..TestPropertyWeight.." stones\nNight Sight\nCharges: "..TestPropertyCharges.Min.." / "..TestPropertyCharges.Max.."\nHit Mana Leech "..TestPropertyHitManaLeech.."%\nPoison Resist "..TestPropertyPoisonResist.."%\nWeapon Speed "..TestPropertyWeaponSpeed.."\nWeapon Damage "..TestPropertyWeaponDamage.Min.." - "..TestPropertyWeaponDamage.Max.."\nSkill Required: "..TestPropertyWeaponSkillRequired

	local function ApplyProperties(item,name,properties)
		UO.Property(item.ID)		;Mock:returns(name,properties)
	end

	local function setUpPropertyItemTable()
		local itemtable = setUpItemTable()
		local propertyitem = itemtable[1]
		ApplyProperties(propertyitem,TestPropertyName,TestPropertyString)
		for i=2,#itemtable do ApplyProperties(itemtable[i],"","") end
		return itemtable, propertyitem
	end

	function TestFilteredItemContainer:test_with_property_filter_equal_to()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").EqualTo(TestPropertyWeight)
			.WithProperty("Skill Required").EqualTo("Fencing")
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_less_than()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").LessThan(TestPropertyWeight + 1)
			.WithProperty("Hit Mana Leech").LessThan(TestPropertyHitManaLeech+1)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_greater_than()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").GreaterThan(TestPropertyWeight - 1)
			.WithProperty("Hit Mana Leech").GreaterThan(TestPropertyHitManaLeech-1)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_greater_than_or_equal_to()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").GreaterThanOrEqualTo(TestPropertyWeight - 5)
			.WithProperty("Hit Mana Leech").GreaterThanOrEqualTo(TestPropertyHitManaLeech)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_less_than_or_equal_to()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").LessThanOrEqualTo(TestPropertyWeight + 5)
			.WithProperty("Hit Mana Leech").LessThanOrEqualTo(TestPropertyHitManaLeech)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_between()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Weight").Between({TestPropertyWeight - 5,TestPropertyWeight + 5})
			.WithProperty("Hit Mana Leech").Between({TestPropertyHitManaLeech - 5,TestPropertyHitManaLeech + 5})
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_like()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("RawProperty").Like("Night Sight")
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_exists()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty("Night Sight").Exists()
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_not_exists()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.Not().WithProperty("Night Sight").Exists()
			.Items

		assertEquals(#filteredItems,#itemtable-1)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_using_function()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithProperty(function(props) return props.NightSight == true end)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_property_filter_using_function_and_not()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.Not().WithProperty(function(props) return props.NightSight == true end)
			.Items

		assertEquals(#filteredItems,#itemtable-1)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_name_filter_using_single_pattern()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithName(TestPropertyName)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_name_filter_using_multiple_pattern()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithName("Fake Name","Fictious Nomenclature",TestPropertyName)
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_name_filter_using_single_table_of_patterns()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithName({"Fake Name","Fictious Nomenclature",TestPropertyName})
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_name_filter_using_multiple_tables_of_patterns()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithName({"Madeup Moniker","Malicious Misnomer"},{"Terrible Attempt At a Fake Name","s7 > RK"},{"Fake Name","Fictious Nomenclature",TestPropertyName})
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_with_name_filter_using_miscellaneous_crap()
		local itemtable, propertyitem = setUpPropertyItemTable()

		Mock:replay()

		local filteredItems = FluentUO.FilteredItemContainer()
			.WithName("Madeup Moniker","Malicious Misnomer",{"Terrible Attempt At a Fake Name","s7 > RK"},"s7 >CEO",{"Fake Name","Fictious Nomenclature",TestPropertyName})
			.Items

		assertEquals(#filteredItems,1)
		assertEquals(filteredItems[1].ID,propertyitem.ID)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_options_set_on_instance_affect_instance_and_do_not_affect_globals()
		local itemtable = setUpItemTable()

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer().Options({TestLocalOption = false})
		local filtereditems = filter.Items

		assertEquals(filter.Options().TestLocalOption,false)
		assertEquals(FluentUO.Options().TestLocalOption,nil)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_options_set_globally_affect_instances()
		local itemtable = setUpItemTable()
		FluentUO.Options({TestGlobalOption = true})

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer()
		local filtereditems = filter.Items

		assertEquals(filter.Options().TestGlobalOption,true)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_options_set_on_instance_affect_instance_and_do_not_affect_globals_using_strings()
		local itemtable = setUpItemTable()

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer().Options("TestInstanceOption",true)
		local filtereditems = filter.Items

		assertEquals(filter.Options().TestInstanceOption,true)
		assertEquals(FluentUO.Options().TestInstanceOption,nil)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_options_set_globally_affect_instances_using_strings()
		local itemtable = setUpItemTable()
		FluentUO.Options("TestGlobalStringOption",true)

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer()
		local filtereditems = filter.Items

		assertEquals(filter.Options().TestGlobalStringOption,true)

		Mock:verify()
	end


	function TestFilteredItemContainer:test_options_find_visible_off()
		local itemtable = setUpItemTableVisibilityDefined(nil,nil,false)

		Mock:replay()

		local filter = FluentUO.FilteredItemContainer().Options("FindVisible",false).Where(function() return true end)
		local filtereditems = filter.Items
		assertEquals(filter.Options().FindVisible, false)

		assertEquals(filtereditems[1].Visible,nil)

		Mock:verify()
	end

	function TestFilteredItemContainer:test_first_filter()
		local itemtable = setUpItemTable()
		local itemexpected = itemtable[1]

		Mock:replay()

		local firstitem = FluentUO.FilteredItemContainer().Where(function() return true end).First

		assertEquals(firstitem.ID,itemexpected.ID)

		Mock:verify()
	end
