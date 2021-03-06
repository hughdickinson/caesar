module Conditions
  class All
    def initialize(dict_name, operation)
      @dict_name = dict_name
      @operation = operation
    end

    def apply(bindings)
      dict = bindings.fetch(@dict_name).data
      dict.keys.all? { |key| @operation.apply({"key" => key, "value" => dict.fetch(key)}) }
    end
  end
end
