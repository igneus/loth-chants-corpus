#!/usr/bin/env bash

# Orchestrates processing pipeline transforming raw extracted data
# to a clean annotated corpus of chant texts

# drop diocese-specific feasts (not interesting for us, have no unique chant texts)
bin/csvfilter.rb -e 'day_title !~ /\(v.+?diecézi\)/' |

    bin/add_cycle_psalter_week.rb |

    bin/add_day_code.rb |

    # keep only one occurrence of each psalter chant
    bin/psalter_clean.rb |
    bin/psalter_uniq.rb |

    # drop first column (filename)
    csvcut --not-columns basename
