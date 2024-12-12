class Api::V1::DashboardController < Api::BaseController
  before_action :check_admin_permission, only: [:create, :return_data]

  def index
    if current_user.staff?
      ids = current_user.user_service_orders.pluck(:service_order_id)
      so = ServiceOrder.where(id: ids)
    else
      so = ServiceOrder
    end

    query = so.where(branch: @branch).includes(:users, :file_data, :result)
              .select('*, service_orders.id as id').order(:month, :so, created_at: :asc)
    if params[:type] == 'done'
      query = query.where(status: :done)
    else
      query = query.where(status: :listing)
    end

    render json: query.as_json(include: { users: { only: [:name] }, file_data: { only: [], methods: :url }, result: [] }), status: :ok
  end

  def get_user_info
    users = User.all.select('id, name')
    render json: users, status: :ok
  end

  def update
    so = ServiceOrder.find_by(id: params[:id])
    if so.update(allow_service_orders)
      render json: so, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def get_so
    id = params[:id]
    render json: ServiceOrder.where(id:).includes(:users).as_json(include: { users: { only: %i[name id] } }),
           status: :ok
  end
  def update_result
    rs = Result.find_or_create_by(service_order_id: params[:id])
    return if rs.service_order.status == 'done'

    if rs.update(allow_params_result)
      FileData.find_or_create_by(service_order_id: params[:id]).update(file: params[:file]) if params[:file]
      render json: rs.slice(:tvpl_load, :tvpl_truck, :tvpl_barge, :total_wh, :discharge, :internal_wh, :external_wh), status: :ok
    else
      render json: { message: rs.errors.full_messages }, status: :bad_request
    end
  end

  def create
    so = ServiceOrder.create(allow_service_orders)
    if so
      render json: so, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def report
    so = ServiceOrder.where(branch: @branch, month: params[:month])
                     .left_joins(:result).select('key_customer, month, location ,tvpl_load, discharge,
                      tvpl_truck, tvpl_barge, internal_wh, external_wh, grand_total, type_cargo, commodity, equipment')
                     .order(:month)
    render json: so.as_json(except: :id)

  end

  def return_data
    data = ServiceOrder.where(id: params[:ids])
    if data.present? && data.update_all(status: :listing)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def update_status
    data = ServiceOrder.where(id: params[:ids])
    if data.present? && data.update_all(status: :done)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  private
  def allow_service_orders
    params.required(:data).permit(:month, :date_so, :so, :so_type, :location, :equipment,
                                  :customer_no, :key_customer, :vendor_key,
                                  :type_cargo, :commodity, :vehicle, :name_of_vessel, :description,
                                  :docs_date, :payment_due_date,
                                  :branch, :bill_of_lading, :contract, :end, :start, :status,
                                  customer: [], vendor: [], user_ids: [])
  end

  def allow_params_result
    params.permit(:tvpl_barge, :tvpl_truck, :tvpl_load, :discharge, :internal_wh, :external_wh)
  end

  def check_admin_permission
    raise `Don't have permission` unless current_user.admin?
  end

end