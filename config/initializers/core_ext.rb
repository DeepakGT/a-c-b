class String
  def to_bool
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

class NilClass
  def to_bool
    false
  end
end

class TrueClass
  def to_bool
    true
  end

  def to_i
    1
  end

  def true?
    true
  end

  def false?
    false
  end
end

class FalseClass
  def to_bool
    false
  end

  def to_i
    0
  end

  def true?
    false
  end

  def false?
    true
  end
end

class Integer
  def to_bool
    to_s.to_bool
  end
end

class Array
  def to_human_string
    arr = Array.new(self)
    if arr.count>1
      last = arr.pop
      return "#{arr.join(", ")} and #{last}"
    end
    arr.first
  end
end
