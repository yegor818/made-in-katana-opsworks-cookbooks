cron "dds_daily_report" do
  hour "4"
  minute "0"
  day "*"
  weekday "*"
  month "*"
  command "/usr/bin/wget -O --timeout=100000 http://goodna.discountdrugstores.com.au/ddsreport/all"
end
