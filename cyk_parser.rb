=begin
Lai varētu izmantot CYK algoritmu, dotā gramatika tika pārveidota Čomska jeb binārajā normālformā.
Rezultātā iegūta šāda gramatika:
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

Doto vārdu pārbaudes rezultāti:
* abbabbabbacabbaaaaabbaac      - PIEDER valodai
* acaaaaaabbaaaaaaaaaaaaaaaaaa  - NEPIEDER valodai
* abbabbabbbbabbabbaaaaabb      - PIEDER valodai
=end
class Parser
  start_symbol = 'S'  # Sākuma simbola noteikšana

  # Gramatikas saglabāšana hash struktūrā mums ērtākā formā (Izvedums ir atslēga un neterminālie simboli, no kuriem var iegūt šos izvedumus, ir vērtības)
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

  # Vārda ievade
  puts "Ievadiet vārdu:"
  string = gets.chomp

  word_length = string.length

  # Izveido CYK algoritmam nepieciešamo tabulu
  cyk_table = Array.new

  for i in 0..(word_length - 1)
    cyk_table << Array.new(word_length - i)
  end

  # CYK Algoritma izveide
  cyk_table.each_with_index do |row, row_nr|
    row.each_with_index do |cell, cell_nr|
      # Katra tabulas rūtiņa ir masīvs
      cyk_table[row_nr][cell_nr] = []      

      # Aizpilda pirmo rindu
      if row_nr == 0
        cyk_table[0][cell_nr] = grammar[string[cell_nr].to_sym] if grammar[string[cell_nr].to_sym]
        cyk_table[0][cell_nr] = cyk_table[0][cell_nr].flatten
      end

      # Aizpila otro rindu, ja tāda eksistē
      if row_nr == 1
        # Apskata visas iespējas, kā var iegūt attiecīgās tabulas šūnas vārdu
        cyk_table[0][cell_nr].each do |array_1_element|
          cyk_table[0][cell_nr + 1].each do |array_2_element|
            substring = array_1_element.to_s + array_2_element.to_s
            cyk_table[1][cell_nr] << grammar[substring.to_sym] if grammar[substring.to_sym]
          end
        end

        cyk_table[1][cell_nr] = cyk_table[1][cell_nr].flatten if cyk_table[1][cell_nr]
      end

      # Aizpilda visas rindas
      if row_nr > 1
        # Apskata visus iespējamos variantus, kā var iegūt vārdu. Iespēju skaits ir rindas numurs.
        for i in 0..(row_nr - 1)
          if cyk_table[i][cell_nr] && cyk_table[row_nr - (i + 1)][cell_nr + (i + 1)]
            # Apskata katra varianta, piemēram aaaab = aa + aab visus variantus kā iegūt aa un kā iegūt aab, un pārbauda, vai tādā veidā var iegūt aaaab. Ja var, tad ieraksta tabulā Neterminālos simbolus, no kuriem var izvest
            cyk_table[i][cell_nr].each do |array_1_element|
              cyk_table[row_nr - (i + 1)][cell_nr + (i + 1)].each do |array_2_element|
                substring = array_1_element.to_s + array_2_element.to_s
                cyk_table[row_nr][cell_nr] << grammar[substring.to_sym] if grammar[substring.to_sym]
              end
            end
          end
        end
      end

      # Iterācijas beigās laukā, ja iespējamo produkciju masīvs sastāv no vairākiem masīviem, tad to saturus apvieno vienā masīvā
      cyk_table[row_nr][cell_nr] = cyk_table[row_nr][cell_nr].flatten if cyk_table[row_nr][cell_nr]
    end
  end

  # CYK algoritma radītās tabulas izdrukāšana
  puts "\n"
  cyk_table.each do |row|
    row_output = row.to_s
    row_output[0] = '|'
    row_output[-1] = '|'
    puts row_output
  end
  puts "\n"

  # Rezultāta paziņošana
  if cyk_table[string.length - 1][0] && cyk_table[string.length - 1][0][0].to_s == start_symbol
    puts "Vārds PIEDER valodai!"
  else
    puts "Vārds NEPIEDER valodai!"
  end
end
