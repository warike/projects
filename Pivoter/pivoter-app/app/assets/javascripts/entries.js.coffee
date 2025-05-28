# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("#entry_entry_type").change ->
    if $("#entry_entry_type").prop("selectedIndex") is 0
      $("#video-url").show()
    else
      $("#video-url").hide()
    return

  fixHelper = (e, ui) ->
    ui.children().each ->
      $(this).width $(this).width()
      return

    ui

  $("#sort tbody").sortable(
    helper: fixHelper
    axis: "y"
    items: "tr"
    stop: (event, ui) ->
      rowCount = $("#sort tr").length - 1
      p = 3
      o = 1

      while o <= rowCount
        $("#sort td:eq(" + p + ")").text o
        p += 5
        o++
      return

    update: ->
      $.post $(this).data("update-url"), $(this).sortable("serialize")
      return
  ).disableSelection()
  return
