class Marketplace::BankAccountsController < AuthenticatedController
  before_action :set_form_submit_url

  def new
    @bank_account = pharmacy.build_bank_account
    authorize @bank_account, :new?
  end

  def create
    @bank_account = pharmacy.build_bank_account(bank_account_params)#Marketplace::BankAccount.new(bank_account_params.merge(marketplace_pharmacy_id: pharmacy&.id))
    authorize @bank_account, :create?
    if @bank_account.valid? && @bank_account.save
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.bank_account.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.bank_account.flash.error')
      render :new
    end
  end

  def edit
    @bank_account = pharmacy.bank_account
    authorize @bank_account, :edit?
  end

  def update
    @bank_account = pharmacy.bank_account
    @bank_account.assign_attributes(bank_account_params.merge(marketplace_pharmacy_id: pharmacy&.id))
    authorize @bank_account, :update?
    if @bank_account.valid? && @bank_account.save!
      redirect_to marketplace_pharmacy_path(pharmacy), flash: { success: I18n.t('marketplace.bank_account.flash.update_successful') }
    else
      flash.now[:warning] = I18n.t('marketplace.bank_account.flash.error')
      render :edit
    end
  end

  private

  def pharmacy
    raise Errors::AccessDenied if current_user.pharmacy? && params.fetch(:pharmacy_id, nil).to_i!=current_user.pharmacy.id
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id))
  end

  def bank_account_params
    params.require(:marketplace_bank_account).permit(:bank_name, :bic, :iban)
  end

  def set_form_submit_url
    @url = marketplace_pharmacy_bank_account_path(pharmacy)
  end
end
