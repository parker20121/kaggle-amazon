class ItemManager < Hash
	
	def add( item, action )
		if has_key?(item)
			# puts "looking up item.."
			count = self[ item ]
		else
			# puts "creating item..."
			count = ItemCount.new(item)
			self[item] = count
		end
		
		count.add( action )
	end
	
	def add_item( item )
		unless has_key?(item)
			self[item] = ItemCount.new(item)
		end
	end
	
	def print
		self.keys.each do |key|
			count = self[key]
			count.print
		end
	end
	
	def percent( item )
		count = self[key]
		 
	end
	
end