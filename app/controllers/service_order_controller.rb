# frozen_string_literal: true
class ServiceOrderController < ApplicationController
  before_action :authenticate_user!, except: [:quote]
  before_action :authenticate_admin!, only: %i[create delete change_status analytics profit data_analytics rollback]

  def index
    redirect_to dashboard_path
  end

  def analytics
    @report_tvpl = ServiceOrder.where(branch: 'tvpl').joins(:result).group(:month).select('service_orders.month, SUM(results.grand_total) as total_grand').order(month: :asc)
    @report_nnp = ServiceOrder.where(branch: 'nnp').joins(:result).group(:month).select('service_orders.month, SUM(results.grand_total) as total_grand').order(month: :asc)
    @grand = ServiceOrder.joins(:result).select(
      'SUM(results.tvpl_load) as total_load',
      'SUM(results.discharge) as total_discharge',
      'SUM(results.tvpl_truck) as total_truck',
      'SUM(results.tvpl_barge) as total_barge',
      'SUM(results.internal_wh + results.external_wh) as total_wh',
      'SUM(results.grand_total) as total_grand'
    )
    @grand_tvpl = ServiceOrder.where(branch: 'tvpl').joins(:result).select(
      'SUM(results.tvpl_load) as total_load',
      'SUM(results.discharge) as total_discharge',
      'SUM(results.tvpl_truck) as total_truck',
      'SUM(results.tvpl_barge) as total_barge',
      'SUM(results.internal_wh + results.external_wh) as total_wh',
      'SUM(results.grand_total) as total_grand'
    )
    @grand_nnp = ServiceOrder.where(branch: 'nnp').joins(:result).select(
      'SUM(results.tvpl_load) as total_load',
      'SUM(results.discharge) as total_discharge',
      'SUM(results.tvpl_truck) as total_truck',
      'SUM(results.tvpl_barge) as total_barge',
      'SUM(results.internal_wh + results.external_wh) as total_wh',
      'SUM(results.grand_total) as total_grand'
    )
  end

  def pivot

  end

  def profit

  end

  def activity
    redirect_to dashboard_path unless current_user.id == 1 || current_user.id == 7
    so_ids = Result.where(updated_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).pluck(:service_order_id)
    @files = ServiceOrder.includes(:result, :users).where(id: so_ids).to_json(include: { result: {}, users: { only: [:name] } })
  end

  def data_analytics
    months = params[:months] || 1
    commodity = ServiceOrder.where(branch: @branch).pluck(:type_cargo).uniq
    arr = []
    if params['type'].present?
      # data = ServiceOrder.where(branch: @branch).includes(:debit_notes, :payment_requests)
      # arr = data
      dn_list = DebitNote.where("EXTRACT(MONTH FROM date) in (?) AND branch = ? AND status = ?", months, @branch, '2').pluck(:so)
      pq_list = PaymentRequest.where('EXTRACT(MONTH FROM payment_date) in (?) AND branch = ? AND status = ?', months, @branch, '2').pluck(:so)
      so_list = (dn_list + pq_list).uniq
      dn_ids = DebitNote.where("EXTRACT(MONTH FROM date) IN (?)  AND branch = ? AND status = ?", months, @branch, '2').ids
      pq_ids = PaymentRequest.where("EXTRACT(MONTH FROM payment_date) in (?)  AND branch = ? AND status = ?", months,@branch, '2').ids
      so_list.each do |s|
        arr.push({ so: s, payment_requests: PaymentRequest.where(id: pq_ids, so: s, status: 2), debit_notes: DebitNote.where(id: dn_ids, so: s, allow: 2) })
      end
      arr = arr.sort_by { |e| e[:so] == '' ? 1 : 0 }
    else

      commodity.each_with_index do |c, i|
        data = ServiceOrder.where(month: months, branch: @branch).joins(:result).group(:key_customer, :type_cargo).select('service_orders.key_customer , SUM(results.tvpl_load) as total_load,
       SUM(results.discharge) as total_discharge, SUM(results.tvpl_truck) as total_truck,
      SUM(results.tvpl_barge) as total_barge,(SUM(results.internal_wh) + SUM(results.external_wh)) as total_wh, SUM(results.grand_total) as total_grand').where(type_cargo: c)
        arr.push({ type_cargo: c, data: })
      end
    end
    if params['type'].present?
      respond_to do |format|
        format.json { render json: { "data": arr.as_json } }
      end
    else
      respond_to do |format|
        format.json { render json: { "data": arr } }
      end

    end

  end

  def delete
    if current_user.id == 1 || current_user.id == 7
      so = ServiceOrder.find_by(id: params[:id])
      so.destroy
      text = { user: current_user.name,
               params:}
      TeleService.send_message(text)
      flash[:notice] = 'Remove SO Successful'
    else
      flash[:notice] = "Don't have permission for this action "
    end
    render js: "window.location = '/dashboard'"
  end

  def rollback
    if current_user.id == 1 || current_user.id == 7
      so = ServiceOrder.find_by(id: params[:id])
      so.update_column(:status, :listing)
      flash[:notice] = 'Update Successful'
    else
      flash[:notice] = "Don't have permission for this action "
    end
    render js: "window.location = '/dashboard'"

  end

  def change_status
    if current_user.id == 1 || current_user.id == 7
      so = ServiceOrder.find_by(id: params[:id])
      so.update_column(:status, :done)
      text = { user: current_user.name,
               params:}
      TeleService.send_message(text)
      flash[:notice] = 'Successful'
    else
      flash[:notice] = "Don't have permission for this action"
    end
    render js: "window.location = '/dashboard'"
  end

  def dashboard
    # ServiceOrder
  end

  def new
    @service_order = ServiceOrder.new
    @service_order.user_service_orders.build
  end

  def edit
    @service_order = ServiceOrder.find(params[:id])
    @service_order.user_service_orders.build
  end

  def update
    @service_order = ServiceOrder.find(params[:service_order][:id])

    if @service_order.update(service_order_params)
      current_user.admin? ? redirect_to(dashboard_path) : redirect_to(business_plans_path)
      flash[:notice] = 'Update Successful'
    else
      flash[:notice] = @service_order.errors.full_messages.join('<br/>')
    end
  end

  def create
    if params[:service_order][:user_service_orders_attributes].present?
      params[:service_order][:user_service_orders_attributes].each_value do |value|
        params[:service_order][:user_service_orders_attributes]['user_id'] = value.map(&:to_i)
      end
    end
    @service_order = ServiceOrder.new(service_order_params)
    if @service_order.save
      redirect_to dashboard_path, notice: 'Service order was successfully created.'
    else
      redirect_to dashboard_new_path
      flash[:notice] = @service_order.errors.full_messages.join('<br/>')
    end
  end

  def data
    query = ServiceOrder.where(branch: @branch).includes(:users).left_joins(:file_data, :result)
                        .select('* , service_orders.id as id, service_orders.description as description').order(:month, :so, created_at: :asc)
    if params[:type] == 'done'
      query = query.where(status: :done)
    else
      query = query.where(status: :listing)
    end
    data = { "data": query }
    respond_to do |format|
      format.json { render json: data.as_json(include: { users: { only: [:name] } }) }
    end
  end

  def quote
    @no_navbar = true
  end

  private

  def service_order_params
    params.require(:service_order).permit(:id, :month, :date_so, :equipment, :so, :commodity, :description, :service,
                                          :location, :type_cargo, :vehicle, :name_of_vessel,
                                          :customer_no, :key_customer, :vendor_key, :so_type,
                                          :branch, user_ids: [], vendor: [], customer: [])
  end
end
