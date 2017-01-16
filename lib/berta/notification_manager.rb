module Berta
  class NotificationManager
    def initialize(service)
      @service = service
    end

    def notify_users(vms)
      send_emails(users_to_notify(vms))
    end

    def users_to_notify(vms)
      uids = []
      vms.each do |vm|
        next if vm.notified
        expiration = vm.expirations.find \
            { |exp| exp.action == Berta::Settings.expiration_offset }
        next unless expiration
        uids.push(vm['UID']) if \
          expiration.time - Time.now.to_i <= Berta::Settings.notification_deadline
      end
      users_from_uids(uids)
    end

    def users_from_uids(uids)
      uids = uids.uniq
      @service.users.keep_all { |user| uids.include?(user['ID']) }
    end

    def send_emails(users); end
  end
end
