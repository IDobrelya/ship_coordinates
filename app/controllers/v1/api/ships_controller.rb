module V1
  module Api
    class ShipsController < ApplicationController
      include Pagy::Backend

      before_action :assign_ship, only: :position
      before_action :find_ship, only: :show

      def index
        @pagy, @positions = pagy(Position.select('
                    DISTINCT ON (positions.ship_id)
                    positions.time as last_time, positions.status as last_status, positions.speed as last_speed,
                    positions.position as last_position, positions.ship_id as ship_id')
                     .order(:ship_id, time: :desc), items: 10)
      end

      def show
        @pagy, @positions =  pagy(@ship.positions.order(time: :desc), items: 10)
      end

      def position
        previous_position = @ship.last_position
        @current_position = @ship.positions.new(position: position_params, time: params[:time])

        @ds = DispatcherService.new(@ship.id, @current_position, previous_position)
        @ds.call

        @current_position.speed = @ds.speed[:main_speed]
        @current_position.status = @ds.status
        @current_position.save
      end

      private

      def find_ship
        @ship = Ship.find(params[:id])
      end

      def assign_ship
        @ship = Ship.find_or_create_by!(id: params[:id])
      end

      def position_params
        params.permit(:x, :y)
      end
    end
  end
end