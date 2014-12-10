submission = File.new("amazon-svm.model.submission.csv","w")
count = 1

submission << "ID,ACTION\n"

File.open("bayes-net.model.results","r") do |infile|
	while ( line = infile.gets )
		index = line.index('*')
		# puts "#{index} #{line[index+1]}"
		submission << "#{count},#{line[-6..-1]}"
	    count = count + 1
	end
end
