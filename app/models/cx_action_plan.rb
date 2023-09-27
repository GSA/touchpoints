class CxActionPlan < ApplicationRecord
    belongs_to :service_provider


    def organization_id
        self.service_provider.organization_id
    end

    def organization_name
        self.service_provider.organization.name
    end

    def service_provider_name
        self.service_provider.name
    end

    def services
        self.service_provider.services
    end
end
