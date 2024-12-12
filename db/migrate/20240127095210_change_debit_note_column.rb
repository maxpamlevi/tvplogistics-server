class ChangeDebitNoteColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :debit_notes, :contract, :string, default: nil
  end
end
