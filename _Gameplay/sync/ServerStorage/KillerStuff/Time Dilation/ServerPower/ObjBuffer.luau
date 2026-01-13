local BufferSize = 20
local BufferArray = {}

local PosBuffer = {}

function PosBuffer.SetBufferSize(value: number)
	BufferSize = value
end

function PosBuffer.Register(Object: Instance)
	BufferArray[Object.Name] = {}
end

function PosBuffer.Unregister(Object: Instance)
	BufferArray[Object.Name] = nil
end

function PosBuffer.IsRegistered(Object: Instance)
	return BufferArray[Object.Name] ~= nil
end

function PosBuffer.AddEntry(Object: Instance, ValueTable: "table")
	
	if (#BufferArray[Object.Name] >= BufferSize) then
		table.remove(BufferArray[Object.Name], 1)
	end

	table.insert(BufferArray[Object.Name], ValueTable)
end

function PosBuffer.GetOldestEntry(Object: Instance)
	return BufferArray[Object.Name][1]
end

function PosBuffer.GetAll(Object: Instance)
	return BufferArray[Object.Name]
end

function PosBuffer.GetAllByType(Type: string)
	local Table = {}
	
	for name, history in pairs(BufferArray) do
		if (history[1]["Type"] == Type) then
			table.insert(Table, name)
		end
	end
	
	return Table
end

return PosBuffer
