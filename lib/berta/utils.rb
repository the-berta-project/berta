module Berta
  # Utility classes
  module Utils
    autoload :OpenNebula, 'berta/utils/opennebula'
    autoload :Filter, 'berta/utils/filter'
    autoload :ExcludeFilter, 'berta/utils/exclude_filter'
    autoload :IncludeFilter, 'berta/utils/include_filter'
  end
end
