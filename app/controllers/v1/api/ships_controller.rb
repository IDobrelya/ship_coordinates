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
        position = { x: params[:x], y: params[:y] }
        new_position_params = { position: position, status: 'green', speed: 10, time: params[:time]}
        @ship.positions.create(new_position_params)

        render json: { time: params[:time], x: params[:x], y: params[:y] }, status: :created
      end

      private

      def find_ship
        @ship = Ship.find(params[:id])
      end

      def assign_ship
        @ship = Ship.find_or_create_by!(id: params[:id])
      end

      def position_params
        params.permit(:time, :x, :y)
      end
    end
  end
end