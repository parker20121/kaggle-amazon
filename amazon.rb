require 'set'

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

rules = {}   # Rulesets index by resource.

approved = Set.new
denied = Set.new
resource = ""

File.open("train.csv", "r") do |infile|
    while (line = infile.gets)
        if count > 0
		
			data = line.split(",")
			
			if resource == "" || resource != data[$RESOURCE]

				if approved.size > 0 || denied.size > 0
					approved_copy = Set.new
					approved_copy.merge( approved )
					denied_copy = Set.new
					denied_copy.merge( denied ) 
					rules[resource] = [ approved_copy, denied_copy ]
					# puts "resource: #{resource} approved: #{approved.size}, denied: #{denied.size}, approved_copy: #{approved_copy.size}, denied_copy: #{denied_copy.size}"
				end
				
				resource = data[$RESOURCE]
				
				approved = Set.new
				denied = Set.new
				
			end
			
			if data[$ACTION] == "1"
				bucket = approved
			else
				bucket = denied
			end
			
			data.each_with_index do |item,index|			
				bucket << item.chomp if index > $RESOURCE				
			end
		
		end
		count = count + 1
    end
end

if approved.size > 0 || denied.size > 0
	approved_copy = Set.new
	approved_copy << approved
	denied_copy = Set.new
	denied_copy << denied
	rules[resource] = [ approved_copy, denied_copy ]
	# puts "resource: #{resource} approved: #{approved_copy.size}, denied: #{denied_copy.size}"
end

puts "resource count: #{rules.size}"

#
# Run test data and create submission file.
#
puts "Generating submission file..."

submission = File.open("submission.csv","w")
submission << "id, ACTION\n" #, RESOURCE, ROLE_CODE\n"

count = 0

File.open("test.csv","r") do |testfile|
	
	while (line = testfile.gets)
		
		# puts "line: #{line}"
		# puts "count: #{count}"
		
		if count > 0 
			data = line.split(",")		
			id = data[$ID]		
			resource = data[$RESOURCE]
			
			# puts "Getting resource #{resource}"
			
			rule = rules[resource]
			approved = rule[0]
			# puts "approved rules: #{approved.size}"
			
			grant_access = true
			deny_access = false
			
			role_code = data[$ROLE_CODE].chomp
			
			grant_access = grant_access && approved.member?(data[$MGR_ID])
			grant_access = grant_access && approved.member?(data[$ROLE_ROLLUP_1])
			grant_access = grant_access && approved.member?(data[$ROLE_ROLLUP_2])
			grant_access = grant_access && approved.member?(data[$ROLE_DEPTNAME])
			grant_access = grant_access && approved.member?(data[$ROLE_TITLE])
			grant_access = grant_access && approved.member?(data[$ROLE_FAMILY])
			grant_access = grant_access && approved.member?(data[$ROLE_FAMILY_DESC])
			grant_access = grant_access && approved.member?(role_code)
						
			if grant_access
				denied = rule[1]
				difference = denied - approved			
				deny_access = deny_access || difference.member?(data[$MGR_ID])
				deny_access = deny_access || difference.member?(data[$ROLE_ROLLUP_1])
				deny_access = deny_access || difference.member?(data[$ROLE_ROLLUP_2])
				deny_access = deny_access || difference.member?(data[$ROLE_DEPTNAME])
				deny_access = deny_access || difference.member?(data[$ROLE_TITLE])
				deny_access = deny_access || difference.member?(data[$ROLE_FAMILY])
				deny_access = deny_access || difference.member?(data[$ROLE_FAMILY_DESC])
				deny_access = deny_access || difference.member?(role_code)
			end
			
			if grant_access && !deny_access
				# submission << "#{id},1,#{data[$RESOURCE]},#{role_code},#{grant_access},#{deny_access}\n"
				submission << "#{id},1\n"
			else
				# submission << "#{id},0,#{data[$RESOURCE]},#{role_code},#{grant_access},#{deny_access}\n"
				submission << "#{id},0\n"
			end		
			
		end
		
		count = count + 1
		
	end
end

puts "Process complete."