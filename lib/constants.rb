require 'calendarium-romanum/cr'

module Cycle
  TEMPORALE = 'temporale'
  SANCTORALE = 'sanctorale'
  PSALTER = 'psalter'
end

# !duplicated in directory 'untranslations'
module Hour
  COMPLINE = 'C'
end

module Genre
  ANTIPHON = 'A'
  RESPONSORY_SHORT = 'Rb'
end

module Position
  GOSPEL_ANTIPHON = 'E'
end

module Season
  CR::Seasons.constants.each do |c|
    const_set c, CR::Seasons.const_get(c).symbol.to_s
  end
end
