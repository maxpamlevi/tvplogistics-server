# frozen_string_literal: true

class AddColumnCompensationToDebitNote < ActiveRecord::Migration[7.1]
  def change
    add_column :debit_notes, :compensation, :float

    reversible do |dir|
      dir.up do
        change_column_default :debit_notes, :allow, nil
        change_column_default :payment_requests, :allow, nil
      end

      dir.down do
        change_column_default :debit_notes, :allow, nil
        change_column_default :payment_requests, :allow, nil
      end
    end
  end
end
