module Woof
  class ArffFile
    attr_reader :relation_name, :attributes, :data, :class_attribute

    #TODO: lots of this stuff is specific to a decision tree.
    def initialize(relation_name, attributes, data, class_attribute)
      @relation_name = relation_name
      @attributes = attributes
      @data = data
      @class_attribute = class_attribute
    end

    def radomize_data_order!
      @data.sort_by! { rand }
      @data
    end

    # Make all continuous attributes discrete
    def continuize!
      @data.each_index do |data_index|
        @data[data_index].each do |attribute_name, attribute|
          att_type = @attributes.find { |attr| attr[:name] == attribute_name }
          #class is a special case. Store original value
          if att_type[:name] == "class" or att_type[:name] == @class_attribute
            @old_class_nominal_attributes = att_type[:nominal_attributes]
          end

          if att_type[:type] == "string" or att_type[:type] == "nominal"
            @data[data_index][attribute_name] = att_type[:nominal_attributes].find_index(attribute)
          end
        end
      end

      #change attribute types
      @attributes.each do |attribute|
        if attribute[:type] == "string" or attribute[:type] == "nominal"
          attribute[:type] = "numeric"
          attribute[:old_nominal_attributes] = attribute[:nominal_attributes]
          attribute[:nominal_attributes] = nil
        end
      end
      self
    end

    def get_training_and_validation_sets(*proportions)
      sum = proportions.inject(0.0) { |memo, obj| memo += obj }
      raise ArgumentError.new("Proportions must add up to 1.0") unless sum == 1.0

      random_data = @data.sort_by { rand }
      sets = []
      proportions.each do |proportion|
        proportion = (proportion * @data.length).floor
        sets << random_data.take(proportion)
      end

      return sets.map do |data|
        ArffFile.new(@relation_name, @attributes, data, @class_attribute)
      end
    end

    def get_class_values
      class_atts = @attributes.find { |att| att[:name] == @class_attribute }
      if class_atts[:nominal_attributes]
        class_atts[:nominal_attributes]
      else
        class_atts[:old_nominal_attributes]
      end
    end

    # Return an array of new ArffFile objects
    # split on the given attribute
    # @pre-condition: attribute is a valid attribute name.
    # @param: attribute - String or Symbol - name of the attribute
    def split_on_attribute(attribute)
      index = find_index_of_attribute(attribute)

      splitted_stuff = {}
      @attributes[index][:nominal_attributes].each do |attribute_value|
        splitted_stuff[attribute_value] = []
      end

      #then remove that attribute?
      @data.each do |data|
        splitted_stuff[data[attribute]] << data.clone
      end

      ret = {}
      splitted_stuff.each do |key, value|
        ret[key] = ArffFile.new(@relation_name.clone, @attributes.clone, value.clone, @class_attribute.clone).remove_attribute(attribute)
      end
      ret
    end

    # Removes an attribute from a dataset.
    # to_remove can be an index or a String or symbol for the attribute name.
    def remove_attribute(to_remove)
      index = 0
      if not to_remove.kind_of? Fixnum
        index = find_index_of_attribute(to_remove)
      else
        index = to_remove
      end
      # binding.pry

      if not index.nil?
        @attributes.delete_at index
        @data.each do |d|
          d.delete to_remove
        end
      end
      self
    end

    def clone
      Marshal::load(Marshal.dump(self))
    end

    def each
      @data.each do |data|
        yield data
      end
    end

    def count
      @data.count
    end

    alias :length :count

    def [](arg)
      dat = @data[arg]
      return ArffFile.new(@relation_name, @attributes, dat, @class_attribute)
    end

    def -(other)
      dat = @data - other.data
      return ArffFile.new(@relation_name, @attributes, dat, @class_attribute)
    end

    def arrange_labels_by_count
      labels = Hash.new(0)
      @data.each do |data|
        labels[data[@class_attribute]] += 1
      end
      labels
    end

    def all_same_label?
      labels = arrange_labels_by_count
      return labels.size == 1
    end

    def get_only_label
      return @data[0][@class_attribute]
    end

    def has_attributes?
      #one of the attributes is the class, so if it has more than one
      #attribute it has attributes.
      return @attributes.size > 1
    end

    def get_most_common_label
      labels = arrange_labels_by_count
      labels.sort { |h1, h2|  h1[1] <=> h2[1] }[-1][0]
    end

    def find_index_of_attribute(attribute_name)
      index = nil
      # puts "calling find_index_of_attribute"
      # puts "@attributes is #{@attributes}"
      @attributes.each_with_index do |att, i|
        index = i if att[:name] == attribute_name.to_s
      end
      index
    end
  end
end
