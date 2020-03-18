(function(){

  const yHeight = 25

  const data =
    ['Bernalillo','Catron','Chaves','Cibola','Colfax','Curry',
     'De Baca','Doña Ana','Eddy','Grant','Guadalupe','Harding','Hidalgo',
     'Lea','Lincoln','Los Alamos','Luna','McKinley','Mora','Otero','Quay',
     'Rio Arriba','Roosevelt','San Juan','San Miguel','Sandoval',
     'Santa Fe','Sierra','Socorro','Taos','Torrance','Union','Valencia']

  var col = d3.selectAll('.names').append('svg')
               .attr('height', 1000)
               .attr('width', 200)

  function highlightLine(name) {
    let svg = d3.select('#covid19-county')
    let line = svg.select(`#${name.replace(' ','-')}`)
    line.attr('stroke-width', 10)
  }

  function unhighlightLine(name) {
    let svg = d3.select('#covid19-county')
    let line = svg.select(`#${name.replace(' ','-')}`)
    line.attr('stroke-width', 2)
  }

  var countyNames = col.selectAll("text")
    .data(data).enter().append('g')
    .on('mouseover', function(county) { highlightLine(county) })
    .on("mouseout", function(county) { unhighlightLine(county) })
    
  countyNames
    .attr('class', 'county-names')
    .append('text').attr('x', 33)
    .attr('y', function(d, i) { return i*yHeight + 17})
    .attr('font-family', 'Nunito Sans')
    .attr("font-size", "25px")
    .text(function(d) {return d })

  countyNames
      .append("circle")
      .attr('id', function(d) { return d })
      .attr("cx", 10).attr("r", 10)
      .attr("cy", function(d, i) { return i*yHeight + 12 })
      .style('fill', function(d, i) { // color nodes
        return d3.interpolateTurbo(i / data.length)
      })

})()