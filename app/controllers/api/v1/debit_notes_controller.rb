# frozen_string_literal: true

class Api::V1::DebitNotesController < Api::BaseController
  def update
    result = DebitNote.find(params[:id])
    if result.update(allow_params)
      render json: result, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def remove
    data = DebitNote.where(id: params[:data])
    if data.blank? || data.detect{ |x| x.pending? || x.done? }.present?
      render json: {}, status: :bad_request
    else
      data.destroy_all
      render json: {}, status: :ok
    end
  end

  def index
    if current_user.staff?
      ids = current_user.user_service_orders.pluck(:service_order_id)
      list = DebitNote.where('branch = ? and ( service_order_id in (?) OR user_id = ? )', @branch, ids, current_user.id)
    else
      list = DebitNote.where(branch: @branch)
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

    list = list.order(:so, date: :asc)

    render json: list.as_json
  end

  def get_pdf
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

    amount_vat = amount.round + ((amount * dnote.first.vat.to_f) / 100).round

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

    pdf_string = render_to_string configs_pdf_file
    sample_data = WickedPdf.new.pdf_from_string pdf_string
    file_name = "Debit note #{Time.zone.today.strftime('%m/%d/%Y')}"

    send_data sample_data, filename: "#{file_name}.pdf", type: 'application/pdf'
  end

  def submit
    return if params[:type].blank?

    value = params[:type].to_sym
    list = DebitNote.where(id: params[:ids])
    if list.present?
      list.update_all(status: value)
      list.update_all(group_id: Time.zone.now.to_i)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def return_data
    render json: {}, status: :bad_request if current_user.staff? || current_user.settlement?

    dn_list = DebitNote.where(id: params[:ids])
    if dn_list.present?
      dn_list.update_all(status: :listing)
      render json: {}, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def create
    data = DebitNote.create!(allow_params.merge(user_id: current_user.id))
    if data
      render json: data.as_json
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def allow_params
    params.require(:data).permit(:payment_date, :amount_vat, :amount, :unit_price, :quantity, :description, :customer,
                                 :so, :vat, :contract, :branch, :status, :refund, :compensation,
                                 :service_order_id, :deposit, :date, :uom)
  end
end
