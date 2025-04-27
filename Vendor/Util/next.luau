return function(value: number, increment: number, wrap: number)
	return (value + increment - 1) % wrap + 1
end
