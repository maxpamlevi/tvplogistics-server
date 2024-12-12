# frozen_string_literal: true

class InformationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[vendors customers add_data update_attr]

  def index; end

  def update_attr
    data = if params[:type] == 'customer'
             Customer.upsert_all(params[:data].values, returning: %w[id])
           else
             Vendor.upsert_all(params[:data].values, returning: %w[id])
           end
    if data
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  def add_data
    data = if params[:type] == 'customer'
             Customer.create!({ name: '' })
           else
             Vendor.create!({ name: '' })
           end
    respond_to do |format|
      format.json { render json: data }
    end
    flash[:notice] = 'Update Successful'
  end

  def vendors
    return unless request.post?

    data = Vendor.all
    respond_to do |format|
      format.json { render json: data.as_json }
    end
  end

  def customers
    return unless request.post?

    data = Customer.all
    respond_to do |format|
      format.json { render json: data.as_json }
    end
  end
end
