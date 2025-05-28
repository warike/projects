class WelcomeController < ApplicationController
  def index
    @visit = Visit.new
  end
end
