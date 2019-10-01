# !/usr/bin/env ruby
require 'active_support'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'date'
require 'csv'

def clean_string(string)
  string.split.select{|t|t.ascii_only?}.join(' ')
end

def str_to_date(date)
  date_str = date.is_a?(Array) ? date.flatten[0] : date.strip
  next_due = date.empty? ? FAR_FUTURE : date
  Date.strptime(date_str, '%m/%d/%Y')
end
# #

LOGIN_URL = 'https://www.dndbeyond.com/sign-in?returnUrl='

def redirect_path(path)
  stub = /(.+force_verify=)/.match(path)[1]
  stub + 'false'
end

def twitch_sign_in
  agent = Mechanize.new
  agent.redirect_ok = true
  agent.user_agent_alias = 'Mac Firefox'
  pg = agent.get(LOGIN_URL)
  lscript = pg.search('script').last
  tw_url = /var _twitchLoginUrl = '(.+)'/.match(lscript)[1]
  path = redirect_path(tw_url)
  pg = agent.get(path)

  form = agent.page.form_with(id: "loginForm")
  form['username'] = 'atapino'
  form['password'] = 'QA169.l355Lawvere'
  form['redirect_path'] = redirect_path(form['redirect_path'])
  # agent.submit(pg.form, pg.form.button)
  signed_in = pg.form.submit

  # pg = agent.get('https://id.twitch.tv/oauth2/authorize?client_id=zd4es4w4g1tqy7q0er6l3i7n2k5en0&force_verify=true&login_type=login&redirect_uri=https%3A%2F%2Fwww.dndbeyond.com%2Flogin-callback&response_type=code&scope=user_read&state=cf2dbe18-9689-426f-a645-928f3f71515d%7C%2F')
  # form = pg.forms.first
  # form['username'] = 'atapino'
  # form['password'] = 'QA169.l355Lawvere'
  # form.submit
  # puts pg.forms.first.keys.map{|k| [k, pg.forms.first[k]].to_s}
  # <form method="post" action="/sessions/new" id="loginForm" class="col-md-6">

  byebug

  pg = agent.get('https://id.twitch.tv/oauth2/authorize?&response_type=code&client_id=zd4es4w4g1tqy7q0er6l3i7n2k5en0&redirect_uri=https://www.dndbeyond.com/login-callback&scope=user_read&state=b0f7deed-b6c3-47f3-ae96-549b91466d79|/&login_type=login&force_verify=false')

  byebug
end

def process
  # agent = Mechanize.new
  # lp = agent.get(TWITCH_LOGIN_URL)

  twitch_sign_in
  # the goal:
  agent.get('https://www.dndbeyond.com/profile/Mortekai/characters/3641195/json')
end


process