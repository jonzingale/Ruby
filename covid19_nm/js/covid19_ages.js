(function(){

var margin = {top: 40, right: 30, bottom: 20, left: 30},
    width = 750 - margin.left - margin.right,
    height = 400 - margin.top - margin.bottom;

var svg = d3.select("#covid19-ages")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");

  d3.csv("./data/age.csv", function(data) {
    var ages = data.columns
    var bins = Object.values(data.slice(-1)[0]) // last record in age.csv

    var x = d3.scaleLinear()
              .domain([0, 12])
              .range([0, width]);

    svg.append("g")
       .attr("transform", "translate(0," + height + ")")
       .call(d3.axisBottom(x).tickValues([]));

    svg.selectAll("text")
        .data(ages).enter()
        .append('text')
        .attr("font-size", "15px")
        .attr("x", function(d, i) { return x(i) + 15 })
        .attr("y", height + 20)
        .text(function(d) { return d });

    var y = d3.scaleLinear()
              .range([height, 0])
              .domain([0, d3.max(bins)])

    svg.append("g").call(d3.axisLeft(y));

    // append the bar rectangles to the svg element
    svg.selectAll("rect")
        .data(bins)
        .enter()
        .append("rect")
          .attr("x", 1)
          .attr("transform", function(d, i) {
            return "translate(" + x(i) + "," + y(d) + ")";
          })
          .attr("width", function(d, i) { return x(i+1) - x(i) -1 ; })
          .attr("height", function(d) { return height - y(d); })
          .style('fill', function(d, i) { return d3.schemeTableau10[i] })
  })
})()