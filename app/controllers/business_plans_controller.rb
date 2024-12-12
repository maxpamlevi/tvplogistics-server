# frozen_string_literal: true

class BusinessPlansController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :update_attr

  def show; end

  def update_done_so
    so = ServiceOrder.find_by(id: params[:id])
    so.update_column(:status, :done)
    text = { user: current_user.name,
             params:}
    TeleService.send_message(text)
    render js: "window.location = '/business_plans'"
    flash[:notice] = 'Status Updated Successful'
  end

  def data
    if (current_user.id == 10 && @branch == 'tvpl') || (current_user.id == 3 && @branch == 'nnp')
      query = ServiceOrder.includes(:users).left_joins(:file_data,
                                                       :result).select('* , service_orders.id as id, service_orders.description as description, service_orders.vendor as vendor').where(branch: @branch)

    else
      if current_user.id == 1 || current_user.id == 7
        query = ServiceOrder.includes(:users).left_joins(:file_data, :result).select('* , service_orders.id as id, service_orders.description as description, service_orders.vendor as vendor').where(
          'service_orders.branch = ?', @branch)
      else
        ids = current_user.user_service_orders.pluck(:service_order_id)
        query = ServiceOrder.includes(:users).left_joins(:file_data, :result).select('* , service_orders.id as id, service_orders.description as description, service_orders.vendor as vendor').where(
          'service_orders.id IN (?) and service_orders.branch = ?', ids, @branch
        )
      end
    end

    if params[:type] == 'done'
      query = query.where(status: :done)
    else
      query = query.where(status: :listing)
    end

    query = query.order(:month, :so, created_at: :asc)
    data = { "data": query }
    respond_to do |format|
      format.json { render json: data.as_json(include: { users: { only: [:name] } }) }
    end
  end

  def update_attr
    bp_id = params[:bp_id]
    if params['data'].key?('vehicle')
      ServiceOrder.find_by(id: bp_id).service_order.update_column(:vehicle, params['data']['vehicle'])
    else
      ServiceOrder.find_by(id: bp_id).update(allow_params)
    end
    render json: { status: :ok }
  end

  private


  def allow_params
    params.require(:data).permit(:contract, :start, :end, :status, :bill_of_lading)
  end
end
