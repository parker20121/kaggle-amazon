require_relative "item_manager"
require_relative "item_count"

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

resources = ItemManager.new

File.open("train.csv", "r") do |infile|
    while (line = infile.gets)
		items = line.split(",")
		resources.add( items[$RESOURCE].chomp.to_i, items[$ACTION].chomp.to_i)
	end
end

resources.print