#!/usr/bin/env bash

# Orchestrates processing pipeline transforming raw extracted data
# to a clean annotated corpus of chant texts

# drop diocese-specific feasts (not interesting for us, have no unique chant texts)
bin/csvfilter.rb -e 'day_title !~ /\(v.+?diecézi\)/' |

    bin/add_cycle_psalter_week.rb |

    bin/add_day_code.rb |

    # keep only one occurrence of each psalter chant
    bin/psalter_clean.rb |
    bin/psalter_uniq.rb > tmp/tmp.csv

bin/csvfilter.rb -e 'cycle == "psalter"' tmp/tmp.csv > tmp/psalter.csv

cat tmp/tmp.csv |

    # drop occurrences of psalter chants in temporale/sanctorale celebrations
    bin/false_flag_psalter_clean.rb tmp/psalter.csv |

    # drop first column (filename)
    csvcut --not-columns basename
