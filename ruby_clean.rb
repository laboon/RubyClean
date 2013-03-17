# Checks a directory recursively for Ruby files and outputs any style
# issues it finds.

# Returns whether or not a line is commented-out.
# @param [String] line - the line to check
# @return [Boolean] true if commented out, false if not
def commented_line?(line)
  /^[[:space:]]*#/.match(line)
end

# Check a commented-out line to see if it may be code.
# @param [String] line - the line to check
# @return [Boolean] true if potentially code, false if not
def possibly_code?(line)
  /puts/.match(line) ||
  /=/.match(line) ||
  /{/.match(line) ||
  /}/.match(line) ||
  /\+/.match(line) ||
  /[[:space:]]+pp[[:space:]]+/.match(line)
end

# Returns whether or not a line has trailing whitespace.
# @param [String] line - the line to check
# @return [Boolean] true if it has trailing whitespace, false if not
def has_trailing_whitespace?(line)
  /[[:space:]]+\Z/.match(line.chomp)
end

def has_hard_tabs?(line)
  /\t+/.match(line)
end

def has_verbal_operators?(line)
  /[[:space:]]+and[[:space:]]+/.match(line) || /[[:space:]]+or[[:space:]]+/.match(line)
end

def do_and_end_same_line?(line)
  /[[:space:]]+do[[:space:]]+.*[[:space:]]+end[[:space:]]+/.match(line)
end

def braces_for_multiline?(line)
  !!/{/.match(line) ^ !!/}/.match(line)
end

def double_pipes_initializing_boolean?(line)
  /\|\|=[[:space:]]*true/.match(line) || /\|\|=[[:space:]]*false/.match(line)
end

# def camel_case_in_method_name?(line)
#   /def[[:space:]]+
# end

def class_variable_used?(line)
  /[[:space:]]+@@/.match(line)
end

def bare_exception_rescued?(line)
  /rescue[[:space:]]+Exception[[:space:]]+/.match(line)
end

def if_with_then?(line)
  /[[:space:]]+if[[:space:]]+/.match(line) && /[[:space:]]+then[[:space:]]+/.match(line)
end

def for_used?(line)
  /[[:space:]]+for[[:space:]]+/.match(line)
end

def method_no_args_with_parens?(line)
  /def[[:space:]]+/.match(line) && /\([[:space:]]*\)/.match(line)
end

# Given a line of code, strip out any strings (e.g. "foo" or 'bar')
# @param
# @return
def strip_strings(line)
  # remove everything between " ", ' ', and / /
end

# Prints out a summary of a line with a possible problem.
# @param [String] file - the file with the problem
# @param [Integer] line_num - the line number of the problem
# @param [String] line - the actual line with the problem
# @param [String] problem - a text indication of the problem (e.g. TRAILING WHITESPACE)
def print_problem(file, line_num, line, problem)
  puts "#{file}:#{line_num} [#{problem}] - #{line}"
end

# Check a file for commented-out code.
# If a line is commented out and is potentially code, print it out along
# with the file name and line number.
# @param [String] file - path to file to check
def check_file(file)
  text = File.open(file).read
  ctr = 0
  text.each_line do |line|
    # puts line
    ctr += 1
    begin      
      
      # Universal (code and comment) style checks
      print_problem(file, ctr, line, "TRAILING WHITESPACE") if has_trailing_whitespace?(line) 
      print_problem(file, ctr, line, "HARD TABS") if has_hard_tabs?(line)

      if !commented_line?(line)
        # Code style checks
        print_problem(file, ctr, line, "VERBAL OPERATORS") if has_verbal_operators?(line) 
        print_problem(file, ctr, line, "SAME-LINE DO ... END") if do_and_end_same_line?(line)
        print_problem(file, ctr, line, "MULTI-LINE { .. }") if braces_for_multiline?(line)
        print_problem(file, ctr, line, "||= INITIALIZING BOOLEAN") if double_pipes_initializing_boolean?(line)
        print_problem(file, ctr, line, "FOR USED") if for_used?(line)
        print_problem(file, ctr, line, "METHOD DEFINITION W/ EMPTY PARENS") if method_no_args_with_parens?(line)
        print_problem(file, ctr, line, "SUPERFLUOUS THEN") if if_with_then?(line)
        print_problem(file, ctr, line, "CLASS VARIABLE USED") if class_variable_used?(line)
        print_problem(file, ctr, line, "BARE EXCEPTION RESCUED") if bare_exception_rescued?(line)
      else
        # Comment style checks
        print_problem(file, ctr, line, "POSS COMMENTED CODE") if possibly_code?(line)
      end
    rescue Exception => e
      # Ignore for now. Probably a UTF-8 problem.
      puts "Exception " + e.to_s
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
