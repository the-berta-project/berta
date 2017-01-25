module Berta
  module Errors
    # Module for entity errors
    module Entities
      autoload :InvalidEntityXMLError, 'berta/errors/entities/invalid_entity_xml_error.rb'
      autoload :NoUserEmailError, 'berta/errors/entities/no_user_email_error.rb'
    end
  end
end
