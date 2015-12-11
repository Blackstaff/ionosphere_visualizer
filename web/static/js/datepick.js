$("#date_range").daterangepicker({
  maxDate: new Date(Date.now()),
  showDropdowns: true,
  locale: {
    format: "DD/MM/YYYY"
  },
  dateLimit: {
    days: 13
  }
});
//$("#date_from_str, #date_to_str").datepicker("setDate", new Date(Date.now()));
