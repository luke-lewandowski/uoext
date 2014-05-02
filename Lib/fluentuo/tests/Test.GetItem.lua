TestGetItem = {}
	local function change_character_position(x,y)
		rawset(UO,'CharPosX',x)
		rawset(UO,'CharPosY',y)
	end

	function TestGetItem:setUp()
		MockUO()
		math.randomseed( os.time() )
		change_character_position(0,0)
	end

	function TestGetItem:test_item_returned_as_table()
		local index = 5;
		local ID, Type, Kind, ContID, X, Y, Z, Stack, Rep, Col = 1,2,3,4,5,6,7,8,9,0

		UO.GetItem(index)	;Mock:returns(ID,Type,Kind,ContID,X,Y,Z,Stack,Rep,Col):atleastonce()

		Mock:replay()

		local item = FluentUO.GetItem(index)
		assertEquals(item.ID, ID)
		assertEquals(item.Type, Type)
		assertEquals(item.Kind, Kind)
		assertEquals(item.ContID, ContID)
		assertEquals(item.X,X)
		assertEquals(item.Y,Y)
		assertEquals(item.Z,Z)
		assertEquals(item.Stack,Stack)
		assertEquals(item.Rep,Rep)
		assertEquals(item.Col,Col)

		Mock:verify()
	end

	function TestGetItem:test_item_distance()
		local ID, Type, Kind, ContID, X, Y, Z, Stack, Rep, Col = 1,2,3,4,5,6,7,8,9,0
		local charpos = { X = 2, Y = 3 }
		change_character_position(charpos.X,charpos.Y)
		local distance = math.max(math.abs(charpos.X - X),math.abs(charpos.Y - Y))

		UO.GetItem(0)	;Mock:returns(ID,Type,Kind,ContID,X,Y,Z,Stack,Rep,Col):atleastonce()

		Mock:replay()

		local item = FluentUO.GetItem(0)
		assertEquals(item.Dist,distance)

		Mock:verify()
	end

	function TestGetItem:test_active_distance()
		local item = randomItem()
		local charpos = { X = 2, Y = 3 }
		local distance = math.max(math.abs(charpos.X - item.X),math.abs(charpos.Y - item.Y))
		change_character_position(charpos.X,charpos.Y)

		UO.GetItem(0)	;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col):atleastonce()

		Mock:replay()

		local gotitem = FluentUO.GetItem(0)
		assertEquals(gotitem.Dist,distance)

		charpos = { X = 1, Y = 1 }
		change_character_position(charpos.X,charpos.Y)
		distance = math.max(math.abs(charpos.X - item.X),math.abs(charpos.Y - item.Y))

		assertEquals(gotitem.Active.Dist(),distance)

		Mock:verify()
	end

	function TestGetItem:test_get_from_metatable_get_property()
		local item = randomItem()
		local expectedname, expectedrawproperty = "Awesomestick","Totally Rad +1"

		UO.GetItem(0)			;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col)
		UO.Property(item.ID)	;Mock:returns(expectedname,expectedrawproperty)

		Mock:replay()

		local gotitem = FluentUO.GetItem(0)
		local property = gotitem.Property

		assertEquals(property.RawProperty,expectedrawproperty)

		Mock:verify()
	end

	function TestGetItem:test_get_from_metatable_get_name()
		local item = randomItem()
		local expectedname, expectedrawproperty = "Beast Slasher","Kicks Major Tail 100%"

		UO.GetItem(0)			;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col)
		UO.Property(item.ID)	;Mock:returns(expectedname,expectedrawproperty)

		Mock:replay()

		local actualitem = FluentUO.GetItem(0)
		local actualname = actualitem.Name

		assertEquals(actualname,expectedname)

		Mock:verify()
	end



	function TestGetItem:test_get_active_property()
		local item = randomItem()
		local expectedname, expectedrawproperty = "Awesomestick","Totally Rad +1"
		local changedproperty = "CEO Slayer"

		UO.GetItem(0)			;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col)
		UO.Property(item.ID)	;Mock:returns(expectedname,expectedrawproperty)
		UO.Property(item.ID)	;Mock:returns(expectedname,changedproperty)

		Mock:replay()

		local gotitem = FluentUO.GetItem(0)
		local property = gotitem.Property

		assertEquals(property.RawProperty,expectedrawproperty)

		local newproperty = gotitem.Active.Property()

		assertEquals(newproperty.RawProperty,changedproperty)
		assert(property.RawProperty ~= newproperty.RawProperty,"Property didn't change")

		Mock:verify()
	end



	function TestGetItem:test_get_active_name()
		local item = randomItem()
		local expectedname, expectedrawproperty = "99 Bottles of Ale","Weight: 99 Stones"
		local changedname = "98 Bottles of Ale"

		UO.GetItem(0)			;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col)
		UO.Property(item.ID)	;Mock:returns(expectedname,expectedrawproperty)
		UO.Property(item.ID)	;Mock:returns(changedname,expectedrawproperty)

		Mock:replay()

		local gotitem = FluentUO.GetItem(0)
		local actualname = gotitem.Name

		assertEquals(actualname,expectedname)

		local newname = gotitem.Active.Name()

		assertEquals(newname,changedname)
		assert(newname ~= actualname,"Name didn't change")

		Mock:verify()
	end


	function TestGetItem:test_invalidate_properties()
		local item = randomItem()
		local expectedname, expectedrawproperty = "Cthulhu's Slimy Toothbrush","Poison Charges: 9999"

		UO.GetItem(0)			;Mock:returns(item.ID,item.Type,item.Kind,item.ContID,item.X,item.Y,item.Z,item.Stack,item.Rep,item.Col)
		UO.Property(item.ID)	;Mock:returns(expectedname,expectedrawproperty):times(2)

		Mock:replay()

		local actualitem = FluentUO.GetItem(0)
		local actualproperty = actualitem.Property
		local actualname = actualitem.Name

		assertEquals(actualproperty.RawProperty,expectedrawproperty)
		assertEquals(actualname,expectedname)

		actualitem.InvalidateProperties()

		assertEquals(rawget(actualitem,"Property"),nil)
		assertEquals(rawget(actualitem,"Name"),nil)

		local secondproperty = actualitem.Property
		local secondname = actualitem.Name

		assertEquals(secondproperty.RawProperty,expectedrawproperty)
		assertEquals(secondname,expectedname)

		assertEquals(secondproperty.RawProperty,actualproperty.RawProperty)
		assertEquals(secondname,actualname)

		Mock:verify()
	end

	function TestGetItem:test_lazy_load_parent_and_rootparent()
		local rootparent = randomItem({ID = 1,Kind = 1})
		local items = {rootparent}
		for i=1,10 do items[#items+1] = randomItem({ID = i+1, ContID = items[#items].ID,Kind = 0}) end
		local child = items[#items]
		local parent = items[#items-1]

		UO.ScanItems(false)		;Mock:returns(#items):anytimes()
		for i=1,#items do
			UO.GetItem(i-1)		;Mock:returns(items[i].ID,items[i].Type,items[i].Kind,items[i].ContID,items[i].X,items[i].Y,items[i].Z,items[i].Stack,items[i].Rep,items[i].Col):anytimes()
		end

		Mock:replay()

		local actualchild = FluentUO.GetItem(#items-1)
		assertEquals(actualchild.ID,child.ID)

		local actualparent = actualchild.Parent
		assertEquals(actualparent.ID,parent.ID)

		local actualrootparent = actualchild.RootParent
		assertEquals(actualrootparent.ID,rootparent.ID)

		Mock:verify()
	end
