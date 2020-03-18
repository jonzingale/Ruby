(function(){

  d3.csv("./data/county.csv", function(data) {
  // d3.csv("./data/random.csv", function(data) { // for testing
    var svg = d3.select('#covid19-county'),
        width = +svg.attr("width"),
        height = +svg.attr("height");

    var win_width = window.innerWidth

    var county_data = {} // make data useable
    data.columns.forEach(function(col_name) {
      let vals = data.map( rec => rec[col_name] )
      county_data[col_name] = vals
    })

    var counties = Object.keys(county_data)//.slice(0,10)
    var numNodes = counties.length
    var series_len = county_data['Bernalillo'].length
    var lineGenerator = d3.line().curve(d3.curveCardinal)

    var xScale = d3.scaleLinear()
      .domain([0, series_len])
      .range([0, win_width])

    counties.forEach(function(county, ci) {
      var timeSeries = county_data[county]
      var max_val = Math.max(...timeSeries)

      var yScale = d3.scaleLinear()
        .domain([0, max_val])
        .range([50, 0])

      var pathData = lineGenerator(
        timeSeries.map( (y, i) => [xScale(i), 2 + ci*24 + yScale(y)] )
      )

      var line = svg.append('g')
        .attr("class", "lines")
        .selectAll('line')
        .data(timeSeries)
        .enter().append('path')
        .attr('id', county.replace(' ','-'))
        .attr("d", pathData)
        .attr("stroke-width", 2).attr("fill", "none")
        .style('stroke', function(d, i) { // color nodes
          return d3.interpolateTurbo(ci / numNodes)
        })
    })
  });
})()