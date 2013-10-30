class Chef
  class Provider
    class Cat < Chef::Provider
      class CatError < RuntimeError
      end

      def load_current_resource
        true
      end

      def action_sell
        true
      end

      def action_blowup
        raise CatError, "CAT BLOWUP"
      end

    end
  end
end
