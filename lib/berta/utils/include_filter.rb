module Berta
  module Utils
    # Filter that includes vms in given params
    class IncludeFilter < Filter
      # Overrides filter method to include vms
      def filter(vmhs)
        idi        = filter_ids(vmhs)
        useri      = filter_users(vmhs)
        groupi     = filter_groups(vmhs)
        clusteri   = filter_clusters(vmhs)
        idi | useri | groupi | clusteri
      end
    end
  end
end
