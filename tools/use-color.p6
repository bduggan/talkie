#!/usr/bin/env perl6

use XML::Class;

my %*SUB-MAIN-OPTS =:named-anywhere;

my $dest = '_colors.scss';
my $sass-cmd = 'sass talkie.scss > talkie.css';

sub MAIN (
    Int $id!,   #= id of the colourlover color (e.g. 4560182, bright_haze)
    Bool :$gen, #= write partial and generate .css from scss
) {

    my $url = "http://www.colourlovers.com/api/palette/$id";
    my $xml = qqx{curl -s $url};

    class Palette does XML::Class[xml-element => 'palette'] {
        has Int $.id is xml-element;
        has $.title is xml-element;
        has Str @.colors is xml-element('hex') 
                        is xml-container('colors');
    }

    my $p = Palette.from-xml($xml);
    my @colors = $p.colors.map: {
        '$color' ~ ++$ ~ ': #' ~ $_ ~ ';'
    }
    my $output = qq:to/DONE/;
        // { $p.title }
        // { $url }

        { @colors.join("\n") }
        DONE
    unless $gen {
        say $output;
    }
    $dest.IO.spurt($output);
    shell $sass-cmd;
}
