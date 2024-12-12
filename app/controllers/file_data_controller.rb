# frozen_string_literal: true

class FileDataController < ApplicationController
  before_action :authenticate_user!
  before_action :check_status, :return_json, only: [:discharge, :barge, :truck, :external, :internal, :so_disc, :so_load, :load ,:so_cont, :so_bk]
  skip_before_action :verify_authenticity_token,
                     only: %i[update_result]

  def edit; end

  def return_json
    id = params[:id]
    @bp = ServiceOrder.find_by(id: id)
    @so = ServiceOrder.find_by(id: id)
  end

  def check_status
    id = params[:id]
    @status = ServiceOrder.find_by(id: id).status
  end

  def update_result
    if ServiceOrder.find_by(id: params[:data][:service_order_id]).status == 'done'
      render json: { message: 'Service Order is done' }, status: :bad_request
      return
    end
    result = Result.find_by(service_order_id: params[:data][:service_order_id])
    params_result = params.require(:data).permit(:service_order_id, :external_wh, :internal_wh, :tvpl_load, :discharge,
                                                 :tvpl_truck, :tvpl_barge)
    result.update(params_result)

    render json: { message: 'Success' }, status: :ok
  end


  def so_bk
    id = params[:id]
    @file = FileData.find_by(service_order_id: id)
    @bol = FileData.find_by(service_order_id: id).bill_of_lading
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
  end
  def so_cont
    id = params[:id]
    @file = FileData.find_by(service_order_id: id)
    @bol = ServiceOrder.find_by(id: id).bill_of_lading
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
  end

  def so_load
    id = params[:id]
    @file = FileData.find_by(service_order_id: id)
    @bol = ServiceOrder.find_by(id: id).bill_of_lading
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
  end

  def so_disc
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
    @bp = ServiceOrder.find_by(id: id)
    @so = ServiceOrder.find_by(id:)
  end

  def internal
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

  def external
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

  def load
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

  def discharge
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

  def barge
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

  def truck
    id = params[:id]
    @permission = current_user.user_service_orders.pluck(:service_order_id).include?(id.to_i)
    @file = FileData.find_by(service_order_id: id)
  end

end
