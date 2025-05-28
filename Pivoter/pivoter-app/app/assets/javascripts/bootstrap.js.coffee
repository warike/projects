jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("[data-toggle='tooltip'], .has-tooltip").tooltip()
  $("[data-behaviour~=datepicker]").datepicker
    format: "yyyy-mm-dd"
    startDate: "+7d"
    endDate: "+28d"
    autoclose: true
