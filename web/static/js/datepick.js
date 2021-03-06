$("#date_range").daterangepicker({
  maxDate: new Date(Date.now()),
  drops: "up",
  showDropdowns: true,
  locale: {
    format: "DD/MM/YYYY"
  },
  dateLimit: {
    days: 13
  }
});

$("#datetime").daterangepicker({
  maxDate: moment.utc(),
  drops: "up",
  showDropdowns: true,
  singleDatePicker: true,
  timePicker: true,
  timePicker24Hour: true,
  timePickerIncrement: 30,
  locale: {
    format: "DD/MM/YYYY HH:mm UTC"
  },
});
