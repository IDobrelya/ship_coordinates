module V1
  module Api
    class ShipsController < ApplicationController
      include Pagy::Backend

      before_action :assign_ship, only: :position
      before_action :find_ship, only: :show

      def index
        latest_positions = Position.select_latest_for_each_ship
        @pagy, @positions = pagy(latest_positions, items: 10, count: 1000)
      end

      def show
        @pagy, @positions = pagy(@ship.positions.order(time: :desc), items: 10, count: 1000)
      end

      def position
        @current_position = build_current_position
        return render_validation_errors unless @current_position.valid?

        @dispatcher_service = DispatcherService.new(
          @ship.id,
          @current_position,
          @ship.last_position
        )
        @dispatcher_service.call

        update_position_attributes(@dispatcher_service)
        @current_position.save
      end

      private

      def build_current_position
        previous_position = @ship.last_position
        position = @ship.positions.new(position: position_params, time: params[:time])
        position.previous_time = previous_position.time if previous_position
        position
      end

      def process_position
        @dispatcher_service = DispatcherService.new(
          @ship.id,
          @current_position,
          @ship.last_position
        )
        @dispatcher_service.call

        update_position_attributes(@dispatcher_service)
        @current_position.save
      end

      def update_position_attributes(service)
        @current_position.speed = service.speed[:main_speed]
        @current_position.status = service.status
      end

      def render_validation_errors
        render json: { errors: @current_position.errors.full_messages }, status: :unprocessable_entity
      end

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