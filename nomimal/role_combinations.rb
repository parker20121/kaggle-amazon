require 'set'
require_relative '../item_manager'
require_relative '../item_count'

class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end

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

resource_comb = Hash.new

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
						
			if resource_comb.has_key?( data[$RESOURCE] )
				comb = resource_comb[ data[$RESOURCE] ]
			else
				comb = Set.new
			end
			
			comb << data[$MGR_ID].chomp
			comb << data[$ROLE_ROLLUP_1].chomp
			comb << data[$ROLE_ROLLUP_2].chomp
			comb << data[$ROLE_DEPTNAME].chomp
			comb << data[$ROLE_TITLE].chomp
			comb << data[$ROLE_FAMILY_DESC].chomp
			comb << data[$ROLE_FAMILY].chomp
			comb << data[$ROLE_CODE].chomp
			
			resource_comb[ data[$RESOURCE] ] = comb
			
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

def contains( field_set, value )
	if field_set.include?( value )
		1
	else
		-1
	end
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
file << "@ATTRIBUTE MGR_ID_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_TITLE_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_FAMILY_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_CODE_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE SEEN_ALL_VALUES {1,-1}\n"
file << "@ATTRIBUTE SEEN_ALL_VALUES_BUT_MANAGER {1,-1}\n"
file << "@ATTRIBUTE SEEN_AT_LEAST_ONE_VALUE {-1,1}\n"

file << "\n@DATA\n"

count = 0

File.open("../train.csv","r") do |infile|
	while ( line = infile.gets )
		unless count == 0 
			index = line.index(",")
			if line[0] == "0"
				file << "-1,#{line[index+1..-2]},"
			else
				file << "1,#{line[index+1..-2]},"
			end
			
			data = line.split(',')
			comb = resource_comb[data[$RESOURCE]]
			
			contains_mgr_id = contains( comb, data[$MGR_ID].chomp)
			contains_role_rollup1 = contains( comb, data[$ROLE_ROLLUP_1].chomp)
			contains_role_rollup2 = contains( comb, data[$ROLE_ROLLUP_2].chomp)
			contains_role_deptname = contains( comb, data[$ROLE_DEPTNAME].chomp)
			contains_role_title = contains( comb, data[$ROLE_TITLE].chomp)
			contains_role_family_desc = contains( comb, data[$ROLE_FAMILY_DESC].chomp)
			contains_role_family = contains( comb, data[$ROLE_FAMILY].chomp)
			contains_role_code = contains( comb, data[$ROLE_CODE].chomp)
			
			contains_all = -1
			contains_all_exclude_manager = -1
			contains_none = -1
			
			flags = [contains_mgr_id, contains_role_rollup1, contains_role_rollup2, contains_role_deptname, contains_role_title, contains_role_family_desc, contains_role_family, contains_role_code]	
			
			if flags.sum == 8 
				contains_all = 1
			end
			
			if flags.sum == 7 
				conatins_all_exclude_manager = 1 
			end
			
			if flags.max == 0 
				contains_none = 1
			end
			
			file << "#{contains_mgr_id},#{contains_role_rollup1},#{contains_role_rollup2},#{contains_role_deptname},"
			file << "#{contains_role_title},#{contains_role_family_desc},#{contains_role_family},#{contains_role_code},"			
			file << "#{contains_all},#{contains_all_exclude_manager},#{contains_none}\n"
			
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
file << "@ATTRIBUTE MGR_ID_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_TITLE_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_FAMILY_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE ROLE_CODE_IN_ROLE {-1,1}\n"
file << "@ATTRIBUTE SEEN_ALL_VALUES {1,-1}\n"
file << "@ATTRIBUTE SEEN_ALL_VALUES_BUT_MANAGER {1,-1}\n"
file << "@ATTRIBUTE SEEN_AT_LEAST_ONE_VALUE {-1,1}\n"
file << "\n@DATA\n"

count = 0

File.open("../test.csv","r") do |infile|
	while ( line = infile.gets )
		unless count == 0 
			index = line.index(',')			
			file << "?,#{line[index+1..-2]},"
			
			data = line.split(',')
			
			comb = resource_comb[data[$RESOURCE]]
			
			contains_mgr_id = contains( comb, data[$MGR_ID].chomp)
			contains_role_rollup1 = contains( comb, data[$ROLE_ROLLUP_1].chomp)
			contains_role_rollup2 = contains( comb, data[$ROLE_ROLLUP_2].chomp)
			contains_role_deptname = contains( comb, data[$ROLE_DEPTNAME].chomp)
			contains_role_title = contains( comb, data[$ROLE_TITLE].chomp)
			contains_role_family_desc = contains( comb, data[$ROLE_FAMILY_DESC].chomp)
			contains_role_family = contains( comb, data[$ROLE_FAMILY].chomp)
			contains_role_code = contains( comb, data[$ROLE_CODE].chomp)			
			
			contains_all = -1
			contains_all_exclude_manager = -1
			contains_none = -1
			
			flags = [contains_mgr_id, contains_role_rollup1, contains_role_rollup2, contains_role_deptname, contains_role_title, contains_role_family_desc, contains_role_family, contains_role_code]
			
			if flags.sum == 8 
				contains_all = 1
			end
			
			if flags.sum == 7 
				conatins_all_exclude_manager = 1 
			end
			
			if flags.max == 0 
				contains_none = 1
			end
					
			file << "#{contains_mgr_id},#{contains_role_rollup1},#{contains_role_rollup2},#{contains_role_deptname},"
			file << "#{contains_role_title},#{contains_role_family_desc},#{contains_role_family},#{contains_role_code},"			
			file << "#{contains_all},#{contains_all_exclude_manager},#{contains_none}\n"			
		end
		
	    count = count + 1
		
	end
end

