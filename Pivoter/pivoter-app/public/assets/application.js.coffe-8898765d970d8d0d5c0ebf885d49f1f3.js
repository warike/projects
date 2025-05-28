(function() {
  $(document).ready(function() {
    $(".select2").select2();
    $("#startup_id").change(function() {
      window.location.href = "../dashboard/" + $("#startup_id").val();
    });
  });

}).call(this);
