	MockUO = function()
		Mock = lemock.controller()
		UO = Mock:mock()
	end

	table.countintablewhere = function(t,fn)
		local count = 0;
		table.foreach(t,function(i,v) if fn(v) then count = count + 1 end end)
		return count
	end

	function ItemBuilder(ID,Type,Kind,ContID,X,Y,Z,Stack,Rep,Col,Visible)
		local t = {}
		if Visible == nil then Visible = true end
		t.ID, t.Type, t.Kind, t.ContID, t.X, t.Y, t.Z, t.Stack, t.Rep, t.Col, t.Visible = ID,Type,Kind,ContID,X,Y,Z,Stack,Rep,Col,Visible
		return t
	end

	---------------------------------------------------------------------------
	-- Generates a random item with valid ranges for the parameters.
	-- @param base a table with values to be used instead of random generation.
	-- @return A random item.
	function randomItem(base)
		base = base or {}
		if base.Visible == nil then base.Visible = ({true,false})[math.random(1,2)] end
		return ItemBuilder(
			base.ID or math.random(0,1000000),
			base.Type or math.random(0,1000000),
			base.Kind or math.random(0,1),
			base.ContID or math.random(0,1000000),
			base.X or math.random(-200,200),
			base.Y or math.random(-200,200),
			base.Z or math.random(-200,200),
			base.Stack or math.random(1,100),
			base.Rep or math.random(1,7),
			base.Col or math.random(0,3000),
			base.Visible
		)
	end
