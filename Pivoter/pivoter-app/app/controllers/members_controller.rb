class MembersController < ApplicationController

before_action :set_member, only: [:destroy]

def destroy
	@startup= Startup.find(@member.startup_id)
	@member.destroy
	redirect_to dashboard_startup_path( @startup.id), :flash => {:success => 'Member was successfully deleted from your #{@startup.name}.'.html_safe}
end

def set_member
  @member = Member.find(params[:id])
end

end
