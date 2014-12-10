require_relative '../item_manager'
require_relative '../item_count'

#
# Note: train.csv must be sorted by resource
#

# Data columns
$ACTION = 0
$ID = 0
$RESOURCE = 1
$MGR_ID = 2
$ROLE_ROLLUP_1 = 3
$ROLE_ROLLUP_2 = 4
$ROLE_DEPTNAME = 5
$ROLE_TITLE = 6
$ROLE_FAMILY_DESC = 7
$ROLE_FAMILY = 8
$ROLE_CODE = 9

count = 0

resource = ItemManager.new
mgr = ItemManager.new
role_rollup1 = ItemManager.new
role_rollup2 = ItemManager.new
role_deptname = ItemManager.new
role_title = ItemManager.new
role_family_desc = ItemManager.new
role_family = ItemManager.new
role_code = ItemManager.new

File.open("../train.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
			data = line.split(",")			
			action = data[$ACTION].to_i
			
			resource.add( data[$RESOURCE].chomp, action )
			mgr.add( data[$MGR_ID].chomp, action )
			role_rollup1.add( data[$ROLE_ROLLUP_1].chomp, action )
			role_rollup2.add( data[$ROLE_ROLLUP_2].chomp, action )
			role_deptname.add( data[$ROLE_DEPTNAME].chomp, action )
			role_title.add( data[$ROLE_TITLE].chomp, action )
			role_family_desc.add( data[$ROLE_FAMILY_DESC].chomp, action )
			role_family.add( data[$ROLE_FAMILY].chomp, action )
			role_code.add( data[$ROLE_CODE].chomp, action )
		end
		count = count + 1
    end
end

#
# Ensure all fields are accounted for.
#
File.open("../test.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
			data = line.split(",")						
			
			resource.add_item( data[$RESOURCE].chomp )
			mgr.add_item( data[$MGR_ID].chomp )
			role_rollup1.add_item( data[$ROLE_ROLLUP_1].chomp )
			role_rollup2.add_item( data[$ROLE_ROLLUP_2].chomp )
			role_deptname.add_item( data[$ROLE_DEPTNAME].chomp )
			role_title.add_item( data[$ROLE_TITLE].chomp )
			role_family_desc.add_item( data[$ROLE_FAMILY_DESC].chomp )
			role_family.add_item( data[$ROLE_FAMILY].chomp )
			role_code.add_item( data[$ROLE_CODE].chomp )
		end
		count = count + 1
    end
end

def list_nomial_field( file, field_name, items )
	
	file << "@ATTRIBUTE #{field_name} \{"
	
	items.keys.each_with_index do | key, index |
		if index == 0
			file << " #{key}"
		else
			file << ", #{key}"
		end
		
	end
	
	file << "}\n"
	
end

#
# Generate training set.
#
file = File.new("train.arff","w")
file << "@RELATION amazon_train\n\n"
file << "@ATTRIBUTE ACTION {-1,1}\n"
list_nomial_field( file, "RESOURCE", resource )
list_nomial_field( file, "MGR_ID", mgr )
list_nomial_field( file, "ROLE_ROLLUP_1", role_rollup1 )
list_nomial_field( file, "ROLE_ROLLUP_2", role_rollup2 )
list_nomial_field( file, "ROLE_DEPTNAME", role_deptname )
list_nomial_field( file, "ROLE_TITLE", role_title )
list_nomial_field( file, "ROLE_FAMILY_DESC", role_family_desc )
list_nomial_field( file, "ROLE_FAMILY", role_family )
list_nomial_field( file, "ROLE_CODE", role_code )
file << "\n@DATA\n"

count = 0

File.open("../train.csv","r") do |infile|
	while ( line = infile.gets )
		unless count == 0 
			index = line.index(",")
			if line[0] == "0"
				file << "-1,#{line[index+1..-1]}"
			else
				file << "1,#{line[index+1..-1]}"
			end
		end
	    count = count + 1
	end
end

#
# Generate test set.
#

file = File.new("test.arff","w")
file << "@RELATION amazon_test\n\n"
# file << "@ATTRIBUTE ID NUMERIC\n"
file << "@ATTRIBUTE ACTION {-1,1}\n"
list_nomial_field( file, "RESOURCE", resource )
list_nomial_field( file, "MGR_ID", mgr )
list_nomial_field( file, "ROLE_ROLLUP_1", role_rollup1 )
list_nomial_field( file, "ROLE_ROLLUP_2", role_rollup2 )
list_nomial_field( file, "ROLE_DEPTNAME", role_deptname )
list_nomial_field( file, "ROLE_TITLE", role_title )
list_nomial_field( file, "ROLE_FAMILY_DESC", role_family_desc )
list_nomial_field( file, "ROLE_FAMILY", role_family )
list_nomial_field( file, "ROLE_CODE", role_code )
file << "\n@DATA\n"

count = 0

File.open("../test.csv","r") do |infile|
	while ( line = infile.gets )
		unless count == 0 
			index = line.index(',')			
			file << "?,#{line[index+1..-1]}"
		end
	    count = count + 1
	end
end
