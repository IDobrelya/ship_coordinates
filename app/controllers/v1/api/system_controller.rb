module V1
  module Api
    class SystemController < ApplicationController
      def flush
        Ship.destroy_all
        $redis.flushall
      end
    end
  end
end