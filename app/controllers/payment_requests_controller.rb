# frozen_string_literal: true

class PaymentRequestsController < ApplicationController
  before_action :authenticate_user!
  # before_action :authenticate_admin!, only: [:update_done_status]
  skip_before_action :verify_authenticity_token,
                     only: %i[create update_attr create_pr_without_so remove_row update_done_status]

  def edit
    @dataSo = ServiceOrder.find_by(id: params[:id])
  end

  def index
    @role = current_user.role
    @vendor = Vendor.select('id, name, dept').all
  end

  def update_done_status
    return if current_user.staff? || current_user.settlement?

    if params[:type] == 'done'
      value = :pending if current_user.admin?
      value = :done if current_user.accountant?
    end
    value = nil if params[:type] == 'return'
    pr_list = PaymentRequest.where(id: params[:data_ids])
    pr_list.update_all(status: value) if pr_list.present?
    render json: { status: :ok }
  end

  def remove_row
    data = PaymentRequest.find_by(id: params[:id])
    data.destroy if data.status == :pending
    text = { user: current_user.name,
             params: }
    TeleService.send_message(text)
    render json: { status: :ok }
  end

  def update_attr
    invoice_no = params[:data].values[0][:invoice_no]
    so = params[:data].values[0][:so]
    # payment_vendor = params[:data].values[0][:payment_vendor]
    invoice_no_list = []
    if invoice_no.present?
      invoice_no_list = PaymentRequest.where(invoice_no:,
                                             payment_vendor: params[:data].values[0][:payment_vendor]).where.not(id: params[:data].values[0][:id])
    end

    if invoice_no_list.present? && (invoice_no_list.pluck(:invoice_date).map { |date| date.year if date.present? }.include?(Date.current.year))
      render json: { status: :dup }
    else
      pay = PaymentRequest.upsert_all(params[:data].values, returning: %w[id])
      if pay
        PaymentRequest.update_pay_due_date(pay)
        render json: { status: :ok }
      else
        render json: { status: :error }
      end
    end

  end

  def create_pr_without_so
    return unless params[:id] == '5x3x'

    pay = PaymentRequest.create!({ description: '', allow: nil, branch: @branch })
    respond_to do |format|
      format.json { render json: pay }
    end
    flash[:notice] = 'Update Successful'
  end

  def show
    ids = params[:ids]
    pay = PaymentRequest.where(id: ids).order(invoice_no: :asc)
    so = ServiceOrder.find_by(id: pay.first.service_order_id)
    vendor = Vendor.find_by(name: pay.first.payment_vendor)

    configs_pdf_file = {
      pdf: 'debit_note',
      template: 'payment_requests/payment_request',
      allow: ["#{Rails.root}/public"],
      locals: {
        pay:,
        first_pay: pay.first,
        so:,
        vendor:
      },
      margin: {
        top: 7,
        bottom: 4,
        left: 7,
        right: 7
      },
      show_as_html: true,
      page_size: 'A4'
    }
    sample_data = render_to_string configs_pdf_file
    file_name = "Payment request #{Time.zone.today.strftime('%m/%d/%Y')}"

    disposition = 'inline'
    disposition = 'attachment' if params[:download] == 'pdf'

    send_data sample_data, type: 'application/pdf; charset=utf-8; header=present',
              disposition: "#{disposition}; filename=#{file_name}.pdf", x_sendfile: true
  end

  def data
    payment_request_list = PaymentRequest.select('*').where(service_order_id: params[:id])
    respond_to do |format|
      format.json { render json: payment_request_list }
    end
  end

  def list
    if current_user.admin? || current_user.accountant? || (current_user.id == 10 && @branch == 'tvpl') || (current_user.id == 3 && @branch == 'nnp')
      pay = PaymentRequest.where("branch = ?", @branch).order(:so, payment_date: :asc)
    else
      ids = current_user.user_service_orders.pluck(:service_order_id)
      pay = PaymentRequest.where("service_order_id in (?) and branch = ?", ids, @branch).order(:so, payment_date: :asc)
    end

    pay = if params[:type] == 'listing'
            pay.where(status: :listing)
          elsif params[:type] == 'pending'
            pay.where(status: :pending)
          else
            pay.where(status: :done)
          end

    payment_request_list = pay.select('payment_vendor ,payment_requests.id as id, so, payment_date, requested_by, pr_no, invoice_date, invoice_no , description, amount_vat, amount, allow, quantity, unit_price, remark , uom, vat, docs_date')
    respond_to do |format|
      format.json { render json: payment_request_list }
    end
  end

  def create
    params.require(:data).values.map do |pr_params|
      param_permit = pr_params.permit(:id, :so, :payment_vendor, :invoice_no, :invoice_date,
                                      :description, :quantity, :unit_price, :amount, :amount_vat,
                                      :docs_date, :payment_due_date, :payment_date, :payment_status, :service_order_id,
                                      :pay_date, :requested_by, :dept, :pr_no, :uom, :allow, :vat, :branch)

      record = PaymentRequest.find_or_initialize_by(id: pr_params[:id])
      record.update(param_permit)
    end

    render json: { status: :ok }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
