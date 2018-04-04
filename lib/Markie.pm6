
my class Node {
    has $.text;
    has $.tag;
    has %.attrs;
    has @.children;
    my sub escape($str) { $str.trans([ '<', '>', '&' ] => [ '&lt;', '&gt;', '&amp;' ], :g) }
    method render {
        if $.tag and $.text and not @.children {
            return "<" ~ $.tag
                  ~ ( join ' ', %.attrs.map: -> (:$key,:$value) { qq[ $key="$value"] } )
                  ~ ">"
                  ~ escape($.text)
                  ~ "</" ~ $.tag ~ ">";
        }
        if $.text and not $.tag and not @.children {
            return escape($.text);
        }
        if @.children {
            return @.children.map({.render}).join('');
        }
        die "don't know how to render " ~ self.perl;
    }
}

my grammar markie {
    rule TOP {
        <line>
    }
    rule line {
        <snippet>+ %% <.ws>
    }
    rule snippet {
        || <inline-code>
        || <multiline-code>
        || <url>
        || <plain>
    }
    rule multiline-code {
        '```'
        <( .+ )>
        '```'
    }
    rule inline-code {
        '`' <( <-[`]>+ )> '`'
    }
    rule plain {
        <-[`\s]>+
    }
    rule url {
        'http' 's'? '://' \S+
    }
}

my class actions {
    method TOP($/) { $/.make: $<line>.made }
    method line($/) { $/.make: Node.new(children => $<snippet>.map: {.made}) }
    method snippet($/) {
        $/.make: $<plain>.made
              // $<inline-code>.made
              // $<multiline-code>.made
              // $<url>.made
          }
    method inline-code($/) { $/.make: Node.new(:tag<pre>, text => "$/", attrs => { class => 'inline' }) }
    method multiline-code($/) { $/.make: Node.new(:tag<pre>, text => "$/", ) }
    method plain($/) { $/.make: Node.new(text => ~$/) }
    method url($/) { $/.make: Node.new(:tag<a>, attrs => { href => "$/" }, text => "$/") }
}

sub md-to-html($str) is export {
    my \p = markie.new;
    my $actions = actions.new;
    my $m = p.parse($str,:$actions) or return $str;
    return $m.made.render;
}
