require 'erb'

module ActiveAdmin
  module HTML

    class Tag < Element
      attr_reader :attributes

      def self.builder_method(method_name)
        ::ActiveAdmin::HTML::BuilderMethods.class_eval <<-EOF, __FILE__, __LINE__
          def #{method_name}(*args, &block)
            insert_tag #{self.name}, *args, &block
          end
        EOF
      end

      def initialize(*)
        super
        @attributes = Attributes.new
      end

      def build(*args)
        super
        attributes = args.extract_options!
        self.content = args.first if args.first

        set_for_attribute(attributes.delete(:for))

        attributes.each do |key, value|
          set_attribute(key, value)
        end
      end

      def set_attribute(name, value)
        @attributes[name.to_sym] = value
      end

      def get_attribute(name)
        @attributes[name.to_sym]
      end
      alias :attr :get_attribute

      def has_attribute?(name)
        @attributes.has_key?(name.to_sym)
      end

      def remove_attribute(name)
        @attributes.delete(name.to_sym)
      end

      def id
        get_attribute(:id)
      end

      # Generates and id for the object if it doesn't exist already
      def id!
        return id if id
        self.id = object_id.to_s
        id
      end

      def id=(id)
        set_attribute(:id, id)
      end

      def add_class(class_names)
        class_list.add class_names
      end

      def remove_class(class_names)
        class_list.delete(class_names)
      end

      # Returns a string of classes
      def class_names
        class_list.to_html
      end

      def class_list
        get_attribute(:class) || set_attribute(:class, ClassList.new)
      end

      def to_html
        "<#{tag_name}#{attributes_html}>#{content}</#{tag_name}>"
      end

      private

      def attributes_html
        attributes.any? ? " " + attributes.to_html : nil
      end

      def set_for_attribute(record)
        return unless record
        set_attribute :id, ActionController::RecordIdentifier.dom_id(record, default_id_for_prefix)
        add_class ActionController::RecordIdentifier.dom_class(record)
      end

      def default_id_for_prefix
        nil
      end

    end

  end
end
