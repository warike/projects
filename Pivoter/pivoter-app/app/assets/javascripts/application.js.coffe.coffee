$(document).ready ->
  $(".select2").select2()
  $("#startup_id").change ->
    window.location.href = "../dashboard/"+$( "#startup_id" ).val();
    return
  return