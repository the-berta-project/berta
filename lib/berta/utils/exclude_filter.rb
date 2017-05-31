module Berta
  module Utils
    # Filter that excludes vms in given params
    class ExcludeFilter < Filter
      # Overrides filter method to exclude vms
      def filter(vmhs)
        ide = filter_ids(vmhs)
        usere = filter_users(vmhs)
        groupe = filter_groups(vmhs)
        clustere = filter_clusters(vmhs)
        vmhs - ide - usere - groupe - clustere
      end
    end
  end
end
