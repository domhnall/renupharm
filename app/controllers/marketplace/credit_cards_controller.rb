class Marketplace::CreditCardsController < AuthenticatedController
  def create
    @credit_card = pharmacy.credit_cards.build(credit_card_params)
    authorize @credit_card, :create?
    if @credit_card.valid? && @credit_card.save && @credit_card.authorize!(shopper_ip: request.remote_ip)
      redirect_to marketplace_pharmacy_profile_path({
        pharmacy_id: pharmacy.id,
        section: 'credit_cards'
      }),
      flash: { success: t('marketplace.credit_card.flash.create_successful') }
    else
      redirect_to marketplace_pharmacy_profile_path({
        pharmacy_id: pharmacy.id,
        section: 'credit_cards'
      }),
      flash: { warning: t('marketplace.credit_card.flash.error') }
    end
  rescue Errors::AccessDenied, Pundit::NotAuthorizedError => exception
    raise e
  rescue StandardError => e
    redirect_to marketplace_pharmacy_profile_path({
      pharmacy_id: pharmacy.id,
      section: 'credit_cards'
    }),
    flash: { error: t('marketplace.credit_card.flash.unexpected_error') }
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def credit_card_params
    params.require(:marketplace_credit_card).permit(:email).merge({
      encrypted_card: params.fetch("adyen-encrypted-data")
    })
  end
end
