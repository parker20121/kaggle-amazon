require_relative 'item_manager'
require_relative 'item_count'

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
roe_code = ItemManager.new

File.open("../train.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
			data = line.split(",").chomp			
			action = data[$ACTION]
			
			resource.add( data[$RESOURCE], action )
			mgr.add( data[$MGR_ID], action )
			role_rollup1.add( data[$ROLE_ROLLUP_1], action )
			role_rollup2.add( data[$ROLE_ROLLUP_2], action )
			role_deptname.add( data[$ROLE_DEPTNAME], action )
			role_title.add( data[$ROLE_TITLE], action )
			role_family_desc.add( data[$ROLE_FAMILY_DESC], action )
			role_family.add( data[$ROLE_FAMILY], action )
			role_code.add( data[$ROLE_CODE], action )
		end
		count = count + 1
    end
end

file = File.new("train.csv")

File.open("../train.csv","r") do |infile|
	while ( line = infile.gets )
		if count == 0
			file << line 
		else
			
		end
	end
end