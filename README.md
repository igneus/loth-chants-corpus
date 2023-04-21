# LOTH chants dataset

Scripts extracting chant texts from the pre-generated HTML provided by
[breviar.sk][breviarsk],
(not only) for purposes of studying liturgical translation.

The dataset itself probably cannot be published without copyright infringement,
but the scripts provide a reproducible way of building it from publicly available sources.

## Prerequisites

- Ruby 3.x, Bundler
- wget
- [csvkit](https://github.com/wireservice/csvkit)

## Usage

- checkout the code
- `bundle install` to install required Ruby packages
- `rake fetch` to fetch and unpack the packages used as input
- `rake extract` to generate the corpus (prints CSV to stdout)

## TODO

- extract OoR responsories
- extract Benedictus/Magnificat antiphons for all three lectionary cycles
- scrape also the Latin and Czech Dominican version
- collate matching entries from different language versions

[breviarsk]: https://breviar.sk/
