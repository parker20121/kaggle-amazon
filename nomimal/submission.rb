submission = File.new("amazon-svm.model.submission.csv","w")
count = 1

File.open("amazon-svm.model.results","r") do |infile|
	while ( line = infile.gets )
		index = line.index('*')
		# puts "#{index} #{line[index+1]}"
		submission << "#{count},#{line[-6..-1]}"
	    count = count + 1
	end
end
