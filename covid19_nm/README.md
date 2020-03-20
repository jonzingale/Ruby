## Covid-19 New Mexico

The Covid-19 corona virus is expected to effect all of us.

This visualizer scrapes New Mexico specific cases from

[nmindepth.com](http://nmindepth.com/interactive-map-new-mexico-covid-19-cases/)
and presents the data as a timeseries.

### SETUP
1. run local server
  - `python -m SimpleHTTPServer 8000`
2. crontab set to run every 6 hours
  - `0 */6 * * * /Users/Jon/Desktop/crude/Ruby/covid19_nm/covid19`
3. visit visualization endpoint
  - [`http://localhost:8000/covid19.html`](http://localhost:8000/covid19.html)
