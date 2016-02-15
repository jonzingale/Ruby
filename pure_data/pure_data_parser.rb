#!/usr/bin/env ruby
require 'activesupport'
require 'byebug'

cwd = '/Users/Jon/Desktop/crude/RubyProcessing/'
# pure_data_file = gets.chomp
pure_data_file = 'test.pd'
pd = File.open(cwd + pure_data_file,'r').read.gsub(/\n/,'').split("\;#")

bary = ['N','N','X','N','X','R','R','N','X','R','R']

def hdata(ns,i,a,as,r,n,rss)
	h = {p_id: r-1, content: a, node: 	i += 1}
	h[:content] == 'N' ? ns << h : h[:p_id] = ns[h[:p_id]][:node]
	hindex(as,n,rss,i,ns).unshift(h)
end

hash = Hash.new({p_id: nil,content: 'N',node: nil})
def hindex(ary,n=1,rss=[1],i=0,ns=[hash])#::String->[Hash]
		a, *as = ary ; r, *rs =rss
		a == 'N' ? hdata(ns,i,a,as,r,n+1,rss.unshift(n+1)) :
		a == 'X' ? hdata(ns,i,a,as,r,n,rss) :
		a == 'R' ? hdata(ns,i,a,as,r,n,rs) : []
end

def tree(ary)#::[Hash]->Tree(Hash)
	tree = Hash.new { |h,k| h[k] = { content: 'N', children: [ ] } }

	ary.each do |n|
	  node, p_id = n.values_at(:node, :p_id)
	  tree[node][:content] = n[:content]
	  tree[p_id][:children].push(tree[node])
	end ; tree
end

tree = tree(hindex(bary))

pp tree
