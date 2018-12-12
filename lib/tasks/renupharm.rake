namespace :renupharm do
  desc "De-activates any listing that is withing 1 week of expiry and notifies seller"
  task remove_expired_listings: [:environment] do
    puts "Processing expired listings ..."
    response = Services::Marketplace::ExpiredListingProcessor.new({
      date: Date.today,
      min_expiry_days: 7
    }).call
    if response.errors.empty?
      puts "Successfully completed processing expired listings"
    else
      puts "Processing expired listings exited with errors:"
      response.errors.each{ |error| puts error.message }
    end
  end
end
