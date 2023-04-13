#!/usr/bin/env bash

# Orchestrates processing pipeline transforming raw extracted data (on the STDIN)
# to a clean corpus of annotated chant texts

tmpfile=tmp/tmp.csv
psalter_csv=tmp/psalter.csv

# drop diocese-specific feasts (not interesting for us, as they have no unique chant texts)
bin/csvfilter.rb -e 'day_title !~ /\(v.+?diecézi\)/' |

    bin/add_cycle_psalter_week.rb |

    bin/add_season.rb |

    bin/add_day_code.rb |

    # keep only one occurrence of each psalter chant
    bin/psalter_clean.rb |
    bin/psalter_uniq.rb |
    bin/saturday_memorial_uniq.rb > $tmpfile

bin/csvfilter.rb -e 'cycle == Cycle::PSALTER' $tmpfile > $psalter_csv

cat $tmpfile |

    # drop occurrences of psalter chants in temporale/sanctorale celebrations
    bin/false_flag_psalter_clean.rb $psalter_csv |

    # drop first column (filename)
    csvcut --not-columns basename |

    uniq
