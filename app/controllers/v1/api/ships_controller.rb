module V1
  module Api
    class ShipsController < ApplicationController
      before_action :assign_ship, only: :position
      before_action :find_ship, only: :show

      def index
        @ships = Ship.includes(:positions)
      end

      def show
        @positions = @ship.last_positions
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