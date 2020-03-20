(function(){

var margin = {top: 40, right: 30, bottom: 20, left: 30},
    width = 660 - margin.left - margin.right,
    height = 400 - margin.top - margin.bottom;

var svg = d3.select("#covid19-ages")
  .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");

  d3.csv("./data/age.csv", function(data) {
    var bins = Object.values(data[0])
    var x = d3.scaleLinear()
        .domain([0, 12])
        .range([0, width]);

    svg.append("g")
        .attr("transform", "translate(0," + height + ")")
        // .call(d3.axisBottom(x));

  // svg.append("text")             
  //     .attr("transform",
  //           "translate(" + (width/2) + " ," + 
  //                          (height + margin.top + 20) + ")")
  //     .style("text-anchor", "middle")
  //     .text("Date");

    var y = d3.scaleLinear().range([height, 0]);
    
    y.domain([0, d3.max(bins, function(d) { return d })]);
    
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