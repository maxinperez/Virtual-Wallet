class SavingGoal < ActiveRecord::Base
    belongs_to :bank_account
    has_many :saving_movements, dependent: :destroy

    validates :name, presence: true
    validates :target_amount, numericality: { greater_than: 0 } # Monto que quiere alcanzar el user
    validates :saved_amount, numericality: { greater_than_or_equal_to: 0 } # Monto que ya tiene guardado

    # ver si alcanzo la meta propuesta
    def reached?
        saved_amount >= target_amount
    end

    # porcentaje del progreso de la meta
    def progress
        [(saved_amount / target_amount) * 100, 100].min.round(2)
    end

    def deposit(amount)
        raise "Monto inválido" if amount <= 0
        raise "Saldo insuficiente" if bank_account.balance < amount

        ActiveRecord::Base.transaction do
            bank_account.update!(balance: bank_account.balance - amount)
            update!(saved_amount: saved_amount + amount)
            saving_movements.create!(
            transaction_type: :deposit,
            amount: amount
            )
        end
    end

    # hacer retiro en el caso que se necesite la plata antes
    def withdraw(amount)
        raise "Monto inválido" if amount <= 0
        raise "No hay suficiente dinero ahorrado" if amount > saved_amount

        ActiveRecord::Base.transaction do
            bank_account.update!(balance: bank_account.balance + amount)
            update!(saved_amount: saved_amount - amount)
            saving_movements.create!(
            transaction_type: :withdraw,
            amount: amount
            )
        end
    end
end