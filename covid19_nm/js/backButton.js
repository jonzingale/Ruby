    var backButton = d3.selectAll('.back-button')
      .append('svg').attr('width', 70).attr('height', 50)
      .append('a').attr('href', function(d) { return '/' })

    backButton
      .append('circle').style('fill','#fff')
      .attr("cx", 21).attr("cy", 21).attr("r", 20)
      .style('stroke','black').attr("stroke-width", 2)

    backButton
      .append('line')
      .style('stroke','black').attr("stroke-width", 2)
      .attr('x1', 31).attr('y1', 4)
      .attr('x2', 31).attr('y2', 37)

    backButton
      .append('line')
      .style('stroke','black').attr("stroke-width", 2)
      .attr('x1', 31).attr('y1', 4)
      .attr('x2', 2).attr('y2', 20)

    backButton
      .append('line')
      .style('stroke','black').attr("stroke-width", 2)
      .attr('x1', 2).attr('y1', 20)
      .attr('x2', 31).attr('y2', 37)