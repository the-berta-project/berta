module Berta
  module Errors
    # Module for entity errors
    module Entities
      autoload :InvalidEntityXMLError, 'berta/errors/entities/invalid_entity_xml_error'
      autoload :NoUserEmailError, 'berta/errors/entities/no_user_email_error'
    end
  end
end
