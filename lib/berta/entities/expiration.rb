module Berta
  module Entities
    # Class for storing expiration data, also can be created from xml
    class Expiration
      attr_reader :id, :time, :action

      # Creates Expiration class instance from XMLElement.
      #
      # @param xml [XMLElement] XML from which to create instance
      # @return [Berta::Entities::Expiration] Expiration from given xml
      # @raise [Berta::Errors::Entities::InvalidEntityXMLError] If XMLElement was not in correct format
      def self.from_xml(xml)
        check_xml!(xml)
        Berta::Entities::Expiration.new(xml['ID'], xml['TIME'], xml['ACTION'])
      end

      # Raises error if XML element is not in correct format.
      #
      # @param xml [XMLElement] XML to check for all required values
      # @raise [Berta::Errors::Entities::InvalidEntityXMLError] If xml is not in correct format
      def self.check_xml!(xml)
        raise Berta::Errors::Entities::InvalidEntityXMLError, 'wrong enxpiration xml recieved' \
          unless %w(ID
                    ACTION
                    TIME).all? { |path| xml.has_elements? path }
      end

      # Creates expiration class instance from given arguments.
      #
      # @param id [String] Schelude action id
      # @param time [String] Schelude action execution time
      # @param action [String] Schelude action
      def initialize(id, time, action)
        @id = id
        @time = time
        @action = action
      end

      # Generate schelude action template that can be used
      # in VMS USER_TEMPLATE/SCHED_ACTION
      #
      # @return [String] Schelude action template
      def template
        <<-EOT
      SCHED_ACTION = [
          ID     = "#{id}",
          ACTION = "#{action}",
          TIME   = "#{time}"
      ]
      EOT
      end

      # Determines if this schelude action is in notification interval.
      # That means its expiration is closer to Time.now than notification
      # deadline.
      #
      # @return [Boolean] Truthy if in notification interval else falsy
      def in_notification_interval?
        time_interval = time.to_i - Time.now.to_i
        time_interval <= Berta::Settings.notification_deadline && time_interval >= 0
      end

      # Determines if this schelude action is in expiration interval.
      # That means its expiration is closer to Time.now that expiration
      # offset.
      #
      # @return [Boolean] Truthy if in expiration interval else falsy
      def in_expiration_interval?
        time_interval = time.to_i - Time.now.to_i
        time_interval <= Berta::Settings.expiration_offset && time_interval >= 0
      end

      # Determines if this expiration has default expiration action set.
      # Default expiration action is action defined in settings file.
      #
      # @return [Boolean] Truthy if has default action else falsy
      def default_action?
        action == Berta::Settings.expiration.action
      end
    end
  end
end
