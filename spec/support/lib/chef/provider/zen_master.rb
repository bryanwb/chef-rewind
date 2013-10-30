class Chef
  class Provider
    class ZenMaster < Chef::Provider
      def load_current_resource
        true
      end

      def action_change
        true
      end
    end
  end
end
