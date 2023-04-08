#!/usr/bin/env bash

# Orchestrates processing pipeline transforming raw extracted data
# to a clean annotated corpus of chant texts

# drop diocese-specific feasts (not interesting for us, have no unique chant texts)
bin/csvfilter.rb -e 'day_title !~ /\(v.+?diecézi\)/' |

    # drop first column (filename)
    csvcut --not-columns basename