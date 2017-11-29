=begin
To use CYK algorhytm grammar should be converted into chomsky normal form
Grammar:
S -> PM | LM | YY | SM | RT | XT | RU | RZ | XU | XZ | FE
A -> YM | EL | MS | XX
E -> EL | MS | XX
F -> RT | XT | RU | RZ | XZ | FE
T -> AU
U -> AZ
R -> AX
N -> XM
O -> EX
P -> XO
L -> XX
M -> YY
X -> a
Y -> b
Z -> c

Examples:
* abbabbabbacabbaaaaabbaac      - BELONGS TO grammar
* acaaaaaabbaaaaaaaaaaaaaaaaaa  - DOES NOT BELONG TO grammar
* abbabbabbbbabbabbaaaaabb      - BELONGS TO grammar
=end
class Parser
  start_symbol = 'S'  # Start symbol

  # Grammar is saved in our comfortable form
  grammar = {
    :PM => [:S],
    :LM => [:S],
    :YY => [:S, :M],
    :SM => [:S],
    :RT => [:S, :F],
    :XT => [:S, :F],
    :RU => [:S, :F],
    :RZ => [:S, :F],
    :XU => [:S],
    :XZ => [:S, :F],
    :FE => [:S, :F],
    :YM => [:A],
    :EL => [:A, :E],
    :MS => [:A, :E],
    :XX => [:A, :E, :L],
    :AU => [:T],
    :AZ => [:U],
    :AX => [:R],
    :XM => [:N],
    :EX => [:O],
    :XO => [:P],
    :c => [:Z],
    :b => [:Y],
    :a => [:X]
  }

  # Word input
  puts "Enter word to check:"
  string = gets.chomp

  word_length = string.length

  # Creates neccessary table for CYK algorhytm
  cyk_table = Array.new

  for i in 0..(word_length - 1)
    cyk_table << Array.new(word_length - i)
  end

  # CYK algorhytm
  cyk_table.each_with_index do |row, row_nr|
    row.each_with_index do |cell, cell_nr|
      # Every cell is array
      cyk_table[row_nr][cell_nr] = []      

      # Fill in first row
      if row_nr == 0
        cyk_table[0][cell_nr] = grammar[string[cell_nr].to_sym] if grammar[string[cell_nr].to_sym]
        cyk_table[0][cell_nr] = cyk_table[0][cell_nr].flatten
      end

      # Fill in second row if it exists
      if row_nr == 1
        cyk_table[0][cell_nr].each do |array_1_element|
          cyk_table[0][cell_nr + 1].each do |array_2_element|
            substring = array_1_element.to_s + array_2_element.to_s
            cyk_table[1][cell_nr] << grammar[substring.to_sym] if grammar[substring.to_sym]
          end
        end
      end

      # Fill all rows
      if row_nr > 1
        for i in 0..(row_nr - 1)
          if cyk_table[i][cell_nr] && cyk_table[row_nr - (i + 1)][cell_nr + (i + 1)]
            cyk_table[i][cell_nr].each do |array_1_element|
              cyk_table[row_nr - (i + 1)][cell_nr + (i + 1)].each do |array_2_element|
                substring = array_1_element.to_s + array_2_element.to_s
                cyk_table[row_nr][cell_nr] << grammar[substring.to_sym] if grammar[substring.to_sym]
              end
            end
          end
        end
      end

      cyk_table[row_nr][cell_nr] = cyk_table[row_nr][cell_nr].flatten if cyk_table[row_nr][cell_nr]
    end
  end

  # show CYK algorhytm table to user
  puts "\n"
  cyk_table.each do |row|
    row_output = row.to_s
    row_output[0] = '|'
    row_output[-1] = '|'
    puts row_output
  end
  puts "\n"

  # Output result
  if cyk_table[string.length - 1][0] && cyk_table[string.length - 1][0][0].to_s == start_symbol
    puts "Word BELONGS to grammar!"
  else
    puts "Word DOES NOT BELONG to grammar!"
  end
end
