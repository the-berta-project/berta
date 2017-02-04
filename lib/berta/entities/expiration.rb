module Berta
  module Entities
    # Class for storing expiration data, also can be created from xml
    class Expiration
      attr_reader :id, :time, :action

      # Creates Expiration class instance from XMLElement
      #
      # @param [XMLElement] from which to create instance
      # @return [Expiration] from param XMLElement
      # @raise [InvalidEntityXMLError] if XMLElement was not in right format
      def self.from_xml(xml)
        check_xml!(xml)
        Berta::Entities::Expiration.new(xml['ID'], xml['TIME'], xml['ACTION'])
      end

      # Raises error if XML element is not in right format
      #
      # @param [XMLElement] xml to check for all paths
      # @raise [InvalidEntityXMLError] if xml is not in right format
      def self.check_xml!(xml)
        raise Berta::Errors::Entities::InvalidEntityXMLError, 'wrong enxpiration xml recieved' \
          unless %w(ID
                    ACTION
                    TIME).all? { |path| xml.has_elements? path }
      end

      def initialize(id, time, action)
        @id = id
        @time = time
        @action = action
      end

      def template
        <<-EOT
      SCHED_ACTION = [
          ID     = "#{id}",
          ACTION = "#{action}",
          TIME   = "#{time}"
      ]
      EOT
      end

      def in_notification_interval?
        time_interval = time.to_i - Time.now.to_i
        time_interval <= Berta::Settings.notification_deadline && time_interval >= 0
      end

      def in_expiration_interval?
        time_interval = time.to_i - Time.now.to_i
        time_interval <= Berta::Settings.expiration_offset && time_interval >= 0
      end

      def default_action?
        action == Berta::Settings.expiration.action
      end
    end
  end
end
