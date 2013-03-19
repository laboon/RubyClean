# Checks directories and/or Ruby files, and outputs any style issues it finds.

# Returns whether or not a line is commented-out.
def commented_line?(line)
  /^[[:space:]]*#/.match(line)
end

# Check a commented-out line to see if it may be code.
def possibly_code?(line)
  /[[:space:]]+puts[[:space:]]+/.match(line) ||
  /=/.match(line) ||
  /{/.match(line) ||
  /}/.match(line) ||
  /\+/.match(line) ||
  /[[:space:]]+pp[[:space:]]+/.match(line)
end

# Returns whether or not a line has trailing whitespace.
def has_trailing_whitespace?(line)
  /[[:space:]]+\Z/.match(line.chomp)
end

# Returns whether or not a line has hard tabs.
def has_hard_tabs?(line)
  /\t+/.match(line)
end

# Returns whether or not a line has verbal Boolean operators (and / or) as opposed
# to the preferred symbolic form ( && / || ).
def has_verbal_operators?(line)
  /[[:space:]]+and[[:space:]]+/.match(line) || /[[:space:]]+or[[:space:]]+/.match(line)
end

# Returns whether or not a line has both do and end on the same line
def do_and_end_same_line?(line)
  /[[:space:]]+do[[:space:]]+.*[[:space:]]+end[[:space:]]+/.match(line)
end

# Returns whether or not a line has a curly brace, but it is not matched on that line
def braces_for_multiline?(line)
  !!/{/.match(line) ^ !!/}/.match(line)
end

# Returns whether the Ruby "set if not already set" operator ||= is used with a 
# Boolean value.
def double_pipes_initializing_boolean?(line)
  /\|\|=[[:space:]]*true/.match(line) || /\|\|=[[:space:]]*false/.match(line)
end

# Returns whether or not a class variable is used.
def class_variable_used?(line)
  /[[:space:]]+@@/.match(line)
end

# Returns whether or not a bare Exception (not a specific kind) is rescued.
def bare_exception_rescued?(line)
  /rescue[[:space:]]+Exception[[:space:]]+/.match(line)
end

# Returns whether or not a superfluous then was used.
def if_with_then?(line)
  /[[:space:]]+if[[:space:]]+/.match(line) && /[[:space:]]+then[[:space:]]+/.match(line)
end

# Returns whether or not a "for" keyword was used.
def for_used?(line)
  /[[:space:]]+for[[:space:]]+/.match(line)
end

# Returns whether or not a method was defined with no arguments but still had parens.
def method_no_args_with_parens?(line)
  /def[[:space:]]+/.match(line) && /\([[:space:]]*\)/.match(line)
end

# Returns whether or not a cramped operator is found.  A cramped operator is an operator
# without space around it (e.g. "foo=a+b" has cramped operators, "foo = a + b" does not).
# Does not yet catch "half-cramped" comparators (e.g. "a< b").
# TODO - does not do division (/).  Gets too confused with regexes.
def cramped_operator?(line)
  /\S[\=\+\-\*\%]\S/.match(line) && !(cramped_comparator?(line))
end

# Returns whether or not a cramped comparator is used.  A cramped comparator is a
# comparator without space around it (e.g. "a<=b" is cramped; "a <= b" is not).
def cramped_comparator?(line)
  /\S(<|<=|>|>=|==|===|!=|<=>)\S/.match(line)
end

# Given a line of code, strip out any strings (e.g. "foo" or 'bar')
# @param [String] line to strip
# @return [String] same line with all specified string data stripped out
def strip_strings(line)
  line.gsub(/\'.*?\'/, "'...'").gsub(/\".*?\"/, "\"...\"").gsub(/\/.*?\//, "\/...\/")
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
    stripped_line = strip_strings(line)
    ctr += 1
    begin            
      # Universal (code and comment) style checks
      print_problem(file, ctr, line, "TRAILING WHITESPACE") if has_trailing_whitespace?(line) 
      print_problem(file, ctr, line, "HARD TABS") if has_hard_tabs?(line)

      if !commented_line?(line)
        # Code style checks
        print_problem(file, ctr, line, "VERBAL OPERATORS") if has_verbal_operators?(stripped_line) 
        print_problem(file, ctr, line, "SAME-LINE DO ... END") if do_and_end_same_line?(stripped_line)
        print_problem(file, ctr, line, "MULTI-LINE { .. }") if braces_for_multiline?(stripped_line)
        print_problem(file, ctr, line, "||= INITIALIZING BOOLEAN") if double_pipes_initializing_boolean?(stripped_line)
        print_problem(file, ctr, line, "FOR USED") if for_used?(stripped_line)
        print_problem(file, ctr, line, "METHOD DEFINITION W/ EMPTY PARENS") if method_no_args_with_parens?(stripped_line)
        print_problem(file, ctr, line, "SUPERFLUOUS THEN") if if_with_then?(stripped_line)
        print_problem(file, ctr, line, "CLASS VARIABLE USED") if class_variable_used?(stripped_line)
        print_problem(file, ctr, line, "BARE EXCEPTION RESCUED") if bare_exception_rescued?(stripped_line)
        print_problem(file, ctr, line, "CRAMPED OPERATOR") if cramped_operator?(stripped_line)
        print_problem(file, ctr, line, "CRAMPED COMPARATOR") if cramped_comparator?(stripped_line)
      else
        # Comment style checks
        print_problem(file, ctr, line, "POSSIBLE COMMENTED CODE") if possibly_code?(line)
      end
    rescue Exception => e
      # Ignore for now. Probably a UTF-8 problem.  That's a style issue in itself, of course.
      # TODO - clean this up.
      puts "Exception " + e.to_s
    end
  end
end

# Traverse a directory path.
# If a Ruby (.rb) file is found, check it for style violations
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
  File.directory?(arg) ? traverse(arg) : check_file(arg)
end
