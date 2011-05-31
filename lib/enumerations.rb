class Enumerations
  def Enumerations.add_item(key,value)
    @hash ||= {}
    @hash[key]=value
  end

  def Enumerations.const_missing(key)
    @hash[key]
  end   

  def Enumerations.each
    @hash.each {|key,value| yield(key,value)}
  end

  def Enumerations.values
    @hash.values || []
  end

  def Enumerations.keys
    @hash.keys || []
  end

  def Enumerations.[](key)
    @hash[key]
  end
end