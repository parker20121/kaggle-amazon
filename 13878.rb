require 'set'

# Data columns
$ACTION = 0
$ID = 0
$RESOURCE = 1
$MRG_ID = 2
$ROLE_ROLLUP_1 = 3
$ROLE_ROLLUP_2 = 4
$ROLE_DEPTNAME = 5
$ROLE_TITLE = 6
$ROLE_FAMILY_DESC = 7
$ROLE_FAMILY = 8
$ROLE_CODE = 9

count = 0

approved = Set.new
denied = Set.new

File.open("13878.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
			data = line.split(",")
			
			if data[$ACTION] == "1"
				bucket = approved
			else
				bucket = denied
			end
			
			data.each_with_index do |item,index|			
				bucket.add( item.chomp ) if index > $RESOURCE				
			end
		
		end
		count = count + 1
    end
end

puts "approved: #{approved.to_a}"
puts
puts "denied: #{denied.to_a}"
puts

difference = denied.subtract(approved)
puts "difference: #{difference.to_a}" 