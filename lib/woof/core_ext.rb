module Enumerable
  def woof_median(&block)
    return nil if self.empty?

    mid = self.length / 2
    if self.length.odd?
      (entries.sort(&block))[mid]
    else
      s = entries.sort(&block)
      (s[mid - 1] + s[mid]).to_f / 2
    end
  end
end
