class Marketplace::CreditCardsController < AuthenticatedController

  def update
    @credit_card = pharmacy.credit_cards.find(params.fetch(:id).to_i)
    authorize @credit_card, :update?
    if @credit_card.update_attributes(params.require(:marketplace_credit_card).permit(:default))
      redirect_to pharmacy_credit_cards_path, flash: { success: t("marketplace.credit_card.flash.update_successful") }
    else
      redirect_to pharmacy_credit_cards_path, flash: { error: t('marketplace.credit_card.flash.unexpected_error') }
    end
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end

  def pharmacy_credit_cards_path
    marketplace_pharmacy_profile_path({ pharmacy_id: pharmacy.id, section: 'credit_cards' })
  end
end
