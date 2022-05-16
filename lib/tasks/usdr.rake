namespace :usdr do
  task load: :environment do
    DigitalServiceAccount.load_service_accounts
    DigitalProduct.load_digital_products
  end
end
