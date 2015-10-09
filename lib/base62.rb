module Base62
  SIXTYTWO = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

  def encode(numeric)
    fail ArgumentError, 'must pass in a number' unless Numeric === numeric

    return '0' if numeric == 0
    s = ''

    while numeric > 0
      s << Base62::SIXTYTWO[numeric.modulo(62)]
      numeric /= 62
    end
    s.reverse
  end

  def decode(base62)
    s = base62.to_s.reverse.split('')

    total = 0
    s.each_with_index do |char, index|
      if ord = SIXTYTWO.index(char)
        total += ord * (62**index)
      else
        fail ArgumentError, "#{base62} has #{char} which is not valid"
      end
    end
    total.to_s
  end

  module_function :encode, :decode
end
