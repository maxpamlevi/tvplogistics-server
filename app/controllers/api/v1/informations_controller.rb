# frozen_string_literal: true

module Api
  module V1
    class InformationsController < Api::BaseController
      before_action :set_information, except: [:customers, :vendors]

      def set_information
        @information = if params[:type] == 'customers'
                         Customer
                       else
                         Vendor
                       end
      end

      def remove
        data = @information.where(id: params[:data])
        if data.blank?
          render json: {}, status: :bad_request
        else
          data.destroy_all
          render json: {}, status: :ok
        end
      end

      def update
        data = @information.upsert_all([params[:data]], returning: %w[id])

        if data
          render json: { message: :ok }, status: :ok
        else
          render json: { message: :error }, status: :bad_request
        end
      end

      def create

        data = @information.create!(allow_params)
        if data
          render json: data.as_json, status: :ok
        else
          render json: {}, status: :bad_request
        end
      end

      def vendors
        data = Vendor.all.order(:id)
        render json: data.as_json
      end

      def customers
        data = Customer.all.order(:id)
        render json: data.as_json
      end

      private
      def allow_params
        if @information == Customer
          return params.require(:data).permit(:name, :tax_no, :address, :customer_no, :dept, :key)
        else
          return params.require(:data).permit(:msncc, :method, :account_no, :bank_name, :name, :dept)
        end
      end
    end
  end
end
