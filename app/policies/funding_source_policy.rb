class FundingSourcePolicy < ApplicationPolicy
  def create?
    return true if user.aba_admin? || user.administrator? || user.bcba?
    
    false
  end

  def update?
    create?
  end
end
