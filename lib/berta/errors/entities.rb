module Berta
  module Errors
    # Module for entity errors
    module Entities
      autoload :InvalidEntityXMLError, 'berta/errors/entities/invalid_entity_xml_error'
      autoload :NoEmailError, 'berta/errors/entities/no_email_error'
    end
  end
end
