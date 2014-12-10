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

resources = ItemManager.new
mgrs = ItemManager.new
role_rollup1s = ItemManager.new
role_rollup2s = ItemManager.new
role_deptnames = ItemManager.new
role_titles = ItemManager.new
role_family_descs = ItemManager.new
role_familys = ItemManager.new
role_codes = ItemManager.new

File.open("../train.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
			data = line.split(",")			
			action = data[$ACTION].to_i
			
			resources.add( data[$RESOURCE].chomp, action )
			mgrs.add( data[$MGR_ID].chomp, action )
			role_rollup1s.add( data[$ROLE_ROLLUP_1].chomp, action )
			role_rollup2s.add( data[$ROLE_ROLLUP_2].chomp, action )
			role_deptnames.add( data[$ROLE_DEPTNAME].chomp, action )
			role_titles.add( data[$ROLE_TITLE].chomp, action )
			role_family_descs.add( data[$ROLE_FAMILY_DESC].chomp, action )
			role_familys.add( data[$ROLE_FAMILY].chomp, action )
			role_codes.add( data[$ROLE_CODE].chomp, action )
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
			
			resources.add_item( data[$RESOURCE].chomp )
			mgrs.add_item( data[$MGR_ID].chomp )
			role_rollup1s.add_item( data[$ROLE_ROLLUP_1].chomp )
			role_rollup2s.add_item( data[$ROLE_ROLLUP_2].chomp )
			role_deptnames.add_item( data[$ROLE_DEPTNAME].chomp )
			role_titles.add_item( data[$ROLE_TITLE].chomp )
			role_family_descs.add_item( data[$ROLE_FAMILY_DESC].chomp )
			role_familys.add_item( data[$ROLE_FAMILY].chomp )
			role_codes.add_item( data[$ROLE_CODE].chomp )
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
list_nomial_field( file, "RESOURCE", resources )
list_nomial_field( file, "MGR_ID", mgrs )
list_nomial_field( file, "ROLE_ROLLUP_1", role_rollup1s )
list_nomial_field( file, "ROLE_ROLLUP_2", role_rollup2s )
list_nomial_field( file, "ROLE_DEPTNAME", role_deptnames )
list_nomial_field( file, "ROLE_TITLE", role_titles )
list_nomial_field( file, "ROLE_FAMILY_DESC", role_family_descs )
list_nomial_field( file, "ROLE_FAMILY", role_familys )
list_nomial_field( file, "ROLE_CODE", role_codes )
file << "@ATTRIBUTE RESOURCE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE RESOURCE_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE MGR_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE MGR_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE TITLE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE TITLE_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_CODE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_CODE_NEGATIVE NUMERIC\n"

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
			
			resource = resources[data[$RESOURCE]]
			file << "#{resource.approve},#{resource.reject},"
			
			mgr = mgrs[data[$MGR_ID]]
			file << "#{mgr.approve},#{mgr.reject},"
			
			role_rollup1 = role_rollup1s[data[$ROLE_ROLLUP_1]]
			file << "#{role_rollup1.approve},#{role_rollup1.reject},"
			
			role_rollup2 = role_rollup2s[data[$ROLE_ROLLUP_2]]
			file << "#{role_rollup2.approve},#{role_rollup2.reject},"
			
			role_deptname = role_deptnames[data[$ROLE_DEPTNAME]]
			file << "#{role_deptname.approve},#{role_deptname.reject},"
			
			title = role_titles[data[$ROLE_TITLE]]
			file << "#{title.approve},#{title.reject},"
			
			role_family_desc = role_family_descs[data[$ROLE_FAMILY_DESC]]
			file << "#{role_family_desc.approve},#{role_family_desc.reject},"
			
			role_family = role_familys[data[$ROLE_FAMILY]]
			file << "#{role_family.approve},#{role_family.reject},"
			
			role_code = role_codes[data[$ROLE_CODE].chomp]
			file << "#{role_code.approve},#{role_code.reject}\n"
			
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
list_nomial_field( file, "RESOURCE", resources )
list_nomial_field( file, "MGR_ID", mgrs )
list_nomial_field( file, "ROLE_ROLLUP_1", role_rollup1s )
list_nomial_field( file, "ROLE_ROLLUP_2", role_rollup2s )
list_nomial_field( file, "ROLE_DEPTNAME", role_deptnames )
list_nomial_field( file, "ROLE_TITLE", role_titles )
list_nomial_field( file, "ROLE_FAMILY_DESC", role_family_descs )
list_nomial_field( file, "ROLE_FAMILY", role_familys )
list_nomial_field( file, "ROLE_CODE", role_codes )
file << "@ATTRIBUTE RESOURCE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE RESOURCE_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE MGR_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE MGR_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP1_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_ROLLUP2_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_DEPTNAME_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE TITLE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE TITLE_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_DESC_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_FAMILY_NEGATIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_CODE_POSITIVE NUMERIC\n"
file << "@ATTRIBUTE ROLE_CODE_NEGATIVE NUMERIC\n"
file << "\n@DATA\n"

count = 0

File.open("../test.csv","r") do |infile|
	while ( line = infile.gets )
		unless count == 0 
			index = line.index(',')			
			file << "?,#{line[index+1..-2]},"
			
			data = line.split(',')
			
			resource = resources[data[$RESOURCE]]
			file << "#{resource.approve},#{resource.reject},"
			
			mgr = mgrs[data[$MGR_ID]]
			file << "#{mgr.approve},#{mgr.reject},"
			
			role_rollup1 = role_rollup1s[data[$ROLE_ROLLUP_1]]
			file << "#{role_rollup1.approve},#{role_rollup1.reject},"
			
			role_rollup2 = role_rollup2s[data[$ROLE_ROLLUP_2]]
			file << "#{role_rollup2.approve},#{role_rollup2.reject},"
			
			role_deptname = role_deptnames[data[$ROLE_DEPTNAME]]
			file << "#{role_deptname.approve},#{role_deptname.reject},"
			
			title = role_titles[data[$ROLE_TITLE]]
			file << "#{title.approve},#{title.reject},"
			
			role_family_desc = role_family_descs[data[$ROLE_FAMILY_DESC]]
			file << "#{role_family_desc.approve},#{role_family_desc.reject},"
			
			role_family = role_familys[data[$ROLE_FAMILY]]
			file << "#{role_family.approve},#{role_family.reject},"
			
			role_code = role_codes[data[$ROLE_CODE].chomp]
			file << "#{role_code.approve},#{role_code.reject}\n"
		end
	    count = count + 1
	end
end

