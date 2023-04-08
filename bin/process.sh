#!/usr/bin/env bash

# Orchestrates processing pipeline transforming raw extracted data
# to a clean annotated corpus of chant texts

csvcut --not-columns basename # drop first column (filename)
