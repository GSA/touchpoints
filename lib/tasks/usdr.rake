namespace :usdr do
  task load: :environment do
    DigitalServiceAccount.import
    DigitalProduct.import
    DigitalProductVersion.import
  end
end
