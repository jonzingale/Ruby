  # a first attempt at saving a deck
  # name, count

module Decks
  attr_reader :deck_1, :corwins_fire_deck, :blue_creature_control,
              :cards_from_zeke
  # this could use another howling mine.
  @deck_1 = {
    'Empyreal Voyager' => 4,
    'Dynavolt Tower' => 2,
    'Condescend' => 2,
    'Unsubstantiate' => 4,
    'Servant of the Conduit' => 2,
    'Breakthrough' => 1,
    'Enclave Cryptologist' => 1,
    'Deadlock Trap' => 2,
    'Woodland Stream' => 2,
    'Longtusk Cub' => 2,
    'Arborback Stomper' => 1,
    'Bristling Hydra' => 1,
    'Confiscation Coup' => 2,
    'Padeem, Consul of Innovation' => 1,
    'Insidious Will' => 1,
    'Pore Over the Pages' => 1,
    'Press for Answers' => 1,
    'Force Spike' => 4,
    'Island' => 6,
    'Forest' => 5,
    'Hinterland Harbor' => 2,
    'Inventors\' Fair' => 2,
    'Evolving Wilds' => 2,
    'Howling Mine' => 1,
    'Aether Hub' => 2,
    'Sylvan Advocate' => 2,
    'Burgeoning' => 2,
    'Echo Mage' => 1,
    'Counterspell' => 4,
    'Sky Skiff' => 1,
    'Thriving Turtle' => 4,
    'Filigree Familiar' => 1,
    'Fabrication Module' => 1
  }

  @corwins_fire_deck = { # 60
    'Mountain' => 7,
    'Dwarven Ruins' => 1,
    'Saprazzan Cove' => 1,
    'Shivan Gorge' => 1,
    'Ghitu Encampment' => 2,
    'Smoldering Crater' => 2,
    'Sandstone Needle' => 1,
    'Forgotten Cave' => 4,
    'Harness the Storm' => 2,
    'Dual Casting' => 1,
    'Shock' => 4,
    'Incinerate' => 4,
    'Lightning Blast' => 2,
    'Lightning Bolt' => 4,
    'Disintegrate' => 3,
    'Deathforge Shaman' => 1,
    'Thermo-Alchemist' => 2,
    'Cinder Pyromancer' => 2,
    'Mana Seism' => 2,
    'Fireball' => 1,
    'Fire Servant' => 1,
    'Crystal Vein' => 1,
    'Sol Ring' => 1,
    'Lava Axe' => 2,
    'Pyre Hound' => 2,
    'Vessel of Volatility' => 4,
    'Dragon\'s Claw' => 2
  }

  @blue_creature_control = { # 63
    'Island' => 10,
    'Thornwood Falls' => 4,
    'Lumbering Falls' => 2,
    'Hinterland Harbor' => 2,
    'Woodland Stream' => 1,
    'Alchemist\'s Refuge' => 2,
    'Howling Mine' => 2,
    'Geth\'s Grimoire' => 1,
    'Skysovereign, Consul Flagship' => 1,
    'Dynavolt Tower' => 4,
    'Burgeoning' => 2,
    'Spreading Seas' => 2, # not enough against non-blue.
    'Breakthrough' => 2,
    'Pore Over the Pages' => 1,
    'Force Spike' => 3,
    'Counterspell' => 4,
    'Condescend' => 2,
    'Broken Ambitions' => 2,
    'Negate' => 1,
    'Unsubstantiate' => 2,
    'Thing in the Ice' => 2,
    'Seasinger' => 4,
    'Echo Mage' => 2,
    'Thriving Turtle' => 2,
    'Enclave Cryptologist' => 1,
    'Padeem, Consul of Innovation' => 2
  }

  @cards_from_zeke = {
    'Arcane Melee' => 1,
    'Amass the Components' => 2,
    'Makeshift Mauler' => 1,
    'Blue Sun\'s Zenith' => 1,
    'Impaler Shrike' => 2,
    'Soul Net' => 1,
    'Tormod\'s Crypt' => 1,
    'Circle of Protection: Red' => 1
  }

end