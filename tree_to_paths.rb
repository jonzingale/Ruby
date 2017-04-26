require 'byebug'

old_tree = {a: {b: {c: nil, d: {e: nil, f: nil}}, g: {h: nil, i: nil}}}
new_tree = {a: {b: {c: nil, j: {e: {k: nil}}, d: {e: nil, f: nil}}, g: {h: nil, i: nil, l: {m: nil}}}}

@paths = []
def tree2Paths(key, val) # nil isn't right here. perhaps is_a?(Hash)
  val.nil? ? @paths << key : val.keys.each { |k| tree2Paths(key + [k], val[k]) }
end

def keys2hash(array)
  array.reverse.reduce({}){ |r, e| {e => r} }
end

# tree.keys is an array with one value
# as tree is a tree and not a forest
tree2Paths(tree.keys, tree.values[0])
# puts @paths.to_s

# merge destroys one or the other :(
that = @paths.each_with_object({}) do |path, accum|
  accum.merge!(keys2hash(path))
end

puts that.to_s


byebug ; 2


default = 
{"admin_settings"=>{"enable_tabs"=>"false"},
 "design_settings"=>
  {"cal_fa"=>"\\f073",
   "select_fa"=>"\\f0dd",
   "title_text"=>"",
   "checkin_text"=>"",
   "checkout_text"=>"",
   "search_button_text"=>"",
   "enable_flex"=>"false"},
 "field_options"=>{"show_cities"=>"false", "show_regions"=>"false"},
 "tab_settings"=>
  {"tabs_dropdown"=>"false",
   "tabs_available"=>
    {"lodgings_tab_on"=>"false",
     "lodgings_tab_text"=>"",
     "lodgings_title_text"=>"",
     "lodgings_checkin_text"=>"",
     "lodgings_checkout_text"=>"",
     "lodgings_search_button_text"=>"",
     "packages_tab_on"=>"false",
     "packages_tab_text"=>"",
     "packages_title_text"=>"",
     "packages_checkin_text"=>"",
     "packages_checkout_text"=>"",
     "packages_search_button_text"=>"",
     "custom_packages_4_tab_on"=>"false",
     "custom_packages_4_tab_text"=>"VISIT PHILLY OVERNIGHT PACKAGES",
     "custom_packages_4_title_text"=>"",
     "custom_packages_4_checkin_text"=>"",
     "custom_packages_4_checkout_text"=>"",
     "custom_packages_4_search_button_text"=>"",
     "custom_lodgings_27_tab_on"=>"false",
     "custom_lodgings_27_tab_text"=>"Mark",
     "custom_lodgings_27_title_text"=>"",
     "custom_lodgings_27_checkin_text"=>"",
     "custom_lodgings_27_checkout_text"=>"",
     "custom_lodgings_27_search_button_text"=>""}}}