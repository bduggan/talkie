use OO::Monitors;
use Talkie::Talk;
use JSON::Fast;
use Log::Async;

class Talkie::Store {
    has Str:D $.dir is required;

    method retrieve-all {
        debug "reading from $.dir";
        my $ids = gather {
            take +$/ if /'talk-' <(\d+)> '.json' / for $.dir.IO.dir;
        }
        $ids.map: -> $id {
            +$id => self.retrieve(+$id)
        }
    }

    method retrieve(Int $id where * > 0 --> Talk) {
        my $file = $.dir.IO.child($id.fmt("talk-%05d.json"));
        return unless $file.IO.e;
        my %vals = from-json( $file.slurp ).grep(*.value.defined);
        Talk.new: |%vals;
    }

    method load-comments(Talk $talk --> Nil) {
        for $.dir.add("comments").dir -> $file {
        }
    }

    method start-writer(Supply $s) {
        debug "Saving talks to { $.dir }";
        $s.tap: -> $talk {
            my $file = $talk.id.fmt('talk-%05d.json');
            mkdir $.dir;
            $.dir.IO.child($file).spurt(to-json(%$talk));
        }
    }
}
