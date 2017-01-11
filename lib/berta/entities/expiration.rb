module Berta
  module Entities
    class Expiration
      attr_reader :id, :time, :action

      def self.from_hash(hash)
        check_hash!(hash)
        Berta::Entities::Expiration.new(hash['ID'], hash['ACTION'], hash['TIME'])
      end

      def self.check_hash!(hash)
        raise Berta::Errors::Entities::InvalidEntityHashError, 'wrong expiration hash recieved' \
          unless %w(ID
                    ACTION
                    TIME).all? { |k| hash.key? k }
      end

      def initialize(id, time, action)
        @id = id
        @time = time
        @action = action
      end
    end
  end
end
