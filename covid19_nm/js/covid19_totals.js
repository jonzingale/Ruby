(function(){
  d3.csv("./data/data.csv", function(data) {
    var svg = d3.select('#covid19-totals'),
        width = +svg.attr("width"),
        height = +svg.attr("height");

    var win_width = window.innerWidth

    var column_data = {} // make data useable
    data.columns.forEach(function(col_name) {
      let vals = data.map( rec => rec[col_name] )
      column_data[col_name] = vals
    })

    var numNodes = data.length
    var lineGenerator = d3.line()//.curve(d3.curveCardinal)

    var xScale = d3.scaleLinear()
      .domain([0, numNodes])
      .range([0, win_width])

    const headers = ['total cases','deaths','recoveries']

    headers.forEach(function(header, ci) {
      let timeSeries = column_data[header]
      let max_val = Math.max(...timeSeries)

      let yScale = d3.scaleLinear()
        .domain([0, max_val])
        .range([120, 0])

      let pathData = lineGenerator(
        timeSeries.map( (y, i) => [xScale(i), 50+yScale(y)] )
      )

      var line = svg.append('g')
        .attr("class", "lines")
        .selectAll('line')
        .data(timeSeries)
        .enter().append('path')
        .attr("d", pathData)
        .attr("stroke-width", 2).attr("fill", "none")
        .style('stroke', function(d, i) {
          return d3.schemeBrBG[3][ci]
        })

      svg.append('text')
        .attr('class', 'label').text(header)
        .attr("x", 510)
        .attr("y", yScale(max_val) + 50)
    })

    // date info
    var dates = column_data['date']

    var lScale = d3.scaleLinear()
      .domain([0, dates.length + 2])
      .range([0, 1000])

    d3.select('#covid19-totals').append('g')
      .attr('class', 'date-label')
      .selectAll('date-labels')
      .data(dates).enter()
      .append('text').attr('class', 'thing')
      .text(function(d) { return d })
      .attr("font-size", "10px")
      .attr("x", function(d, i) { return lScale(i) })
      .attr("y", 200)

  });
})()