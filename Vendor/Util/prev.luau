return function(value: number, decrement: number, wrap: number)
	return (value - decrement + wrap - 1) % wrap + 1
end
