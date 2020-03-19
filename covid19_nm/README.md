### Covid-19 New Mexico

The Covid-19 corona virus is expected to effect all of us.

This visualizer scrapes New Mexico specific cases from

[nmindepth.com](http://nmindepth.com/2020/03/13/map-new-mexico-covid-19-cases/)
and presents the data as a timeseries.

### SETUP
1. create `data` directory with two csv files
2. run local server
3. crontab set to run every 6 hours
4. visit endpoint

```
mkdir data
echo 'date,time,total cases,deaths,recoveries' > data/data.csv
echo 'Bernalillo,Catron,Chaves,Cibola,Colfax,Curry,De Baca,Doña Ana,Eddy,Grant,Guadalupe,Harding,Hidalgo,Lea,Lincoln,Los Alamos,Luna,McKinley,Mora,Otero,Quay,Rio Arriba,Roosevelt,San Juan,San Miguel,Sandoval,Santa Fe,Sierra,Socorro,Taos,Torrance,Union,Valencia' > data/county.csv

python -m SimpleHTTPServer 8000`

0 */6 * * * /Users/Jon/Desktop/crude/Ruby/covid19_nm/covid19

[`http://localhost:8000/covid19.html`](http://localhost:8000/covid19.html)
```