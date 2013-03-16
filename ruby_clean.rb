# Check a commented-out line to see if it may be code.
# @param [String] line - the line to check
# @return [Boolean] true if potentially code, false if not
def possibly_code?(line)
  if  /puts/.match(line) ||
      /=/.match(line) ||
      /{/.match(line) ||
      /}/.match(line) ||
      /\+/.match(line) ||
      /[[:space:]]+pp[[:space:]]+/.match(line)
    true
  else
    false
   end
end

# Check a file for commented-out code.
# If a line is commented out and is potentially code, print it out along
# with the file name and line number.
# @param [String] file - path to file to check
def check_file(file)
  text = File.open(file).read
  ctr = 0
  text.each_line do |line|
    ctr += 1
    begin
      if /^[[:space:]]*#/.match(line) 
        puts "#{file}:#{ctr} - #{line}" if possibly_code?(line)
      end
    rescue Exception => e
      # Ignore for now. Probably a UTF-8 problem.
    end
  end
end

# Traverse a directory path.
# If a Ruby (.rb) file is found, check it for potential commented-out code
# @param [String] directory - root directory to traverse
def traverse (directory) 
  Dir.chdir(directory) do
    Dir.glob("**/*") do |f|
      file = File.stat(f)
      check_file f if file.file? && File.extname(f) == '.rb' 
    end
  end
end

# For each command-line argument passed in, traverse that directory and
# read in each file.
ARGV.each do |arg|
  traverse arg
end
