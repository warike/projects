module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"
# Funcion para almacenar la id de la startup (startup_id) que permite optimizar las query por visitas
# se utiliza en dentro del modelo Startup
  before_save :set_startup
    def set_startup
      self.startup_id = self.properties[:startup_id]
      self.country = self.properties[:country_id]
    end
    
    belongs_to :visit
    belongs_to :user
    belongs_to :startup

    
  end
end
