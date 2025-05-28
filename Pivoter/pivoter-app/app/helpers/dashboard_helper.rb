#!/bin/env ruby
# encoding: utf-8

module DashboardHelper
  def flash_class(tipo_mensaje ,value)
    if(value.is_a?(Hash))
      icon_value=value[:icon]
      value=value[:text]
    end
    icon_value= icon_value.nil? ? 'warning-sign': icon_value
    icon = 'glyphicon glyphicon-' + icon_value
      case tipo_mensaje
  
          when :notice then 
            content_tag :div, class: "alert alert-info" do
              concat content_tag(:span, ' ', :class =>icon)
              concat button_tag("×", type: 'button', class: "close", data: {dismiss: "alert"})
              concat " "
              concat value
            end
  
          when :success then 
            content_tag :div, class: "alert alert-success" do
              concat content_tag(:span, ' ', :class =>icon)
              concat button_tag("×", type: 'button', class: "close", data: {dismiss: "alert"})
              concat " "
              concat value
            end
  
          when :error then
            content_tag :div, class: "alert alert-danger" do
              concat content_tag(:span, ' ', :class =>icon)
              concat button_tag("×", type: 'button', class: "close", data: {dismiss: "alert"})
              concat " "
              concat value
            end

  
          when :alert then 
            content_tag :div, class: "alert alert-warning" do
              concat content_tag(:span, ' ', :class =>icon)
              concat button_tag("×", type: 'button', class: "close", data: {dismiss: "alert"})
              concat " "
              concat value
            end
  
      end
  end
  
  def select_startups(selected = nil)
    has_startups = current_user.startups.count
    if(has_startups>0)
      select("startup", "id", User.startups_by_member(current_user.id).collect {|p| [ p.name, p.id ] }, { include_blank: false , :prompt => "Select your startup" , :selected => selected },{ :class => 'form-control select2'})
    else
      link_to '<button type="button" class="btn btn-info input-lg  col-xs-8 ">Create</button>'.html_safe, '#'
    end
  end

  def guest_user_login
    if !user_signed_in?
      concat flash_class('notice' ,"Hey remember to <b><u>create your account</u></b> clicking here.".html_safe)
    end
  end
  
end
