# frozen_string_literal: true

class DebitNotesController < ApplicationController
  before_action :authenticate_user!
  # before_action :authenticate_admin!, only: [:update_done_status]
  skip_before_action :verify_authenticity_token,
                     only: %i[create create_pr_without_so update_attr update_done_status remove_row]

  def edit
    @dataSo = ServiceOrder.find_by(id: params[:id])
  end

  def update_done_status
    return if current_user.staff? || current_user.settlement?

    if params[:type] == 'done'
      value = :pending if current_user.accountant?
      value = :done if current_user.admin?
    end
    value = nil if params[:type] == 'return'
    dn_list = DebitNote.where(id: params[:data_ids])
    dn_list.update_all(status: value) if dn_list.present?

    render json: { status: :ok }
  end

  def update_attr
    if params[:data].values.first[:vat] == ''
      params[:data].values.first[:vat] = 0
    end
    dnote = DebitNote.upsert_all(params[:data].values, returning: %w[id])
    if dnote
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  def create_pr_without_so
    return unless params[:id] == '5x3x'

    pay = DebitNote.create!({ description: '', allow: nil, branch: @branch })
    respond_to do |format|
      format.json { render json: pay }
    end
    flash[:notice] = 'Update Successful'
  end

  def show
    ids = params[:ids]

    dnote = DebitNote.where(id: ids)
    so_id = dnote.first.service_order_id
    so = if so_id.present?
           ServiceOrder.find(so_id)
         else
           []
         end

    amount = dnote.sum do |debit|

      debit.unit_price.to_f * debit.quantity.to_f
    end

    amount_vat = amount.round + ((amount * dnote.first.vat) / 100).round

    str = ''
    deposit = dnote.sum(:deposit)

    compensation = dnote.sum(:compensation)

    if compensation.present? && compensation.positive?
      str = 'Bồi thường hao hụt/ <i>Compensation for loss</i>'
      value = amount_vat - compensation
    end

    if deposit.present? && deposit.positive?

      str = if amount_vat > deposit
              'Cần thanh toán thêm/ <i>To - be - paid</i>'
            else
              'Hoàn lại/ <i>Refund</i>'
            end
      value = amount_vat - deposit
    end
    configs_pdf_file = {
      pdf: 'debit_note',
      template: 'debit_notes/debit_note',
      allow: ["#{Rails.root}/public"],
      locals: {
        dn: dnote,
        first_dn: so,
        deposit:,
        compensation:,
        amount:,
        amount_vat:,
        str:,
        paid: value
      },
      margin: {
        top: 7,
        bottom: 4,
        left: 7,
        right: 7
      },
      show_as_html: false,
      page_size: 'A4'
    }

    sample_data = render_to_string configs_pdf_file

    disposition = 'inline'
    disposition = 'attachment' if params[:download] == 'pdf'

    file_name = "Debit note #{Time.zone.today.strftime('%m/%d/%Y')}"

    send_data sample_data, type: 'application/pdf; charset=utf-8; header=present',
              disposition: "#{disposition}; filename=#{file_name}.pdf", x_sendfile: true
  end

  def data
    id = params[:id]
    query = DebitNote.select('*').where(service_order_id: id)
    respond_to do |format|
      format.json { render json: query }
    end
  end

  def list
    if current_user.staff?
      ids = current_user.user_service_orders.pluck(:service_order_id)
      dn_list = DebitNote.where("service_order_id in (?) and branch = ?", ids, @branch).order(:so, date: :asc)
    else
      dn_list = DebitNote.where("branch = ?", @branch).order(:so, date: :asc)
    end

    if params[:type] == 'listing'
      dn_list = dn_list.where(status: :listing)
    elsif params[:type] == 'pending'
      dn_list = dn_list.where(status: :pending)
    else
      dn_list = dn_list.where(status: :done)
    end

    query = dn_list
    respond_to do |format|
      format.json { render json: query }
    end
  end

  def remove_row
    dn_data = DebitNote.find_by(id: params[:id])
    dn_data.destroy if dn_data.status == :pending
    text = { user: current_user.name,
             params:}
    TeleService.send_message(text)
    render json: { status: :ok }
  end

  def create
    params.require(:data).values.map do |dn_params|
      param_permit = dn_params.permit(:id, :so, :payment_date, :amount_vat, :amount, :unit_price, :quantity,
                                      :description, :uom, :customer, :service_order_id, :date, :allow,
                                      :compensation, :vat, :contract, :branch, :deposit, :refund, :created_at, :updated_at)
      record = DebitNote.find_or_initialize_by(id: dn_params[:id])
      record.update(param_permit)
    end

    render json: { status: :ok }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def index
    @role = current_user.role
  end

  private

  def allow_params
    params.require(:data).permit(:payment_date, :amount_vat, :amount, :unit_price, :quantity, :description, :customer, :vat, :contract, :branch)
  end
end
