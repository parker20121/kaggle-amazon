$APPROVE = 1
$REJECT = 0

class ItemCount
		
	def initialize( item )
		@item = item
		@approve = 0
		@reject = 0
	end
	
	def item
		item
	end
	
	def approve
		@approve
	end
	
	def reject
		@reject
	end
	
	def add( action )
		if action == $REJECT
			@reject = @reject + 1
		else
			@approve = @approve + 1
		end
	end
	
	def print
		puts "#{@item}, #{@approve}, #{@reject}"
	end
	
	def percent( action )
		if action == $REJECT
			@reject/total
		else
			@approve/total
		end
	end
	
	def total
		@approve + @reject
	end
	
end