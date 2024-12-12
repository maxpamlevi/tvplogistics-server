# frozen_string_literal: true

class Api::V1::PaymentRequestsController < Api::BaseController

  def update
    result = PaymentRequest.find(params[:id])
    if result.update(allow_params)
      PaymentRequest.update_pay_due_date([result])
      render json: result, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def remove
    data = PaymentRequest.where(id: params[:data])
    if data.blank? || data.detect { |x| x.pending? || x.done? }.present?
      render json: {}, status: :bad_request
    else
      data.destroy_all
      render json: {}, status: :ok
    end
  end

  def index
    if current_user.admin? || current_user.accountant? || (current_user.id == 10 && @branch == 'tvpl') || (current_user.id == 3 && @branch == 'nnp')
      list = PaymentRequest.where("branch = ?", @branch)
    else
      ids = current_user.user_service_orders.pluck(:service_order_id)
      list = PaymentRequest.where('branch = ? and ( service_order_id in (?) OR user_id = ? )', @branch, ids, current_user.id)
    end

    if params[:id].present?
      list = list.where(service_order_id: params[:id])
    end

    list = if params[:type] == 'listing'
             list.where(status: :listing)
          elsif params[:type] == 'pending'
            list.where(status: :pending)
          else
            list.where(status: :done)
          end

    list = list.order(:so, payment_date: :asc)

    render json: list.as_json
  end

  def get_pdf

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
    sample_data = WickedPdf.new.pdf_from_string sample_data
    file_name = "Payment request #{Time.zone.today.strftime('%m/%d/%Y')}"

    send_data sample_data, filename: "#{file_name}.pdf", type: 'application/pdf'
  end

  def submit
    return if params[:type].blank?

    value = params[:type].to_sym
    list = PaymentRequest.where(id: params[:ids])
    if list.present?
      list.update_all(status: value)
      list.update_all(group_id: Time.zone.now.to_i)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def return_data
    raise "Don't have permission" if current_user.staff?

    dn_list = PaymentRequest.where(id: params[:ids])
    if dn_list.present?
      dn_list.update_all(status: :listing)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def create
    data = PaymentRequest.create!(allow_params.merge(user_id: current_user.id))
    if data
      render json: data.as_json
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def allow_params
    params.require(:data).permit(:id, :so, :payment_vendor, :invoice_no, :invoice_date,
                                 :description, :quantity, :unit_price, :amount, :amount_vat,
                                 :docs_date, :payment_due_date, :payment_date, :payment_status, :service_order_id,
                                 :pay_date, :requested_by, :dept, :pr_no, :uom, :allow, :vat, :branch, :status)
  end
end
