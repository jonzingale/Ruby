# <div class="liveNow" style="display: none;"><span class="liveNowStatusIcon"></span><span>Live Now</span></div>
# <a href="http://www.pandora.com/david-byrne/live-from-austin-texas/life-during-wartime-live" class="songTitle">Life During Wartime (Live)</a>


# http://www.pandora.com/station/play/2795165807499474637
# http://www.pandora.com/station/play/
# <link rel="canonical" href="/station/play/2795165807499474637"
require 'mechanize'
require 'launchy'
require 'byebug'

agent = Mechanize.new
# page = agent.get('http://www.pandora.com/station/play/2795165807499474637')

page = agent.get('http://www.pandora.com/')

Launchy.open 'http://www.pandora.com/station/play/2795165807499474637'

# How to submit the forms?

# It would be a great idea to feel the liveNow following-sibling a_tag
# to know when to switch stations.

page.at('.//div[@class="liveNow"]/following-sibling::a')['href']
byebug ; 4