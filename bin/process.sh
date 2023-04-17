#!/bin/bash -e

# Orchestrates processing pipeline transforming raw extracted data (on the STDIN)
# to a clean corpus of annotated chant texts

# drop diocese-specific feasts (not interesting for us, as they have no unique chant texts)
bin/csvfilter.rb -e 'day_title !~ /\(v.+?diecézi\)/' |

    # drop first column (filename)
    csvcut --not-columns basename |

    uniq
