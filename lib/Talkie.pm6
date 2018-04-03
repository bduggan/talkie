use OO::Monitors;
use Talkie::Store;
use Talkie::Talk;
use JSON::Fast;
use Log::Async;

monitor Talkie {
    has %.conf;
    has Int $next-id = 1;
    has Talk %!talks-by-id{Int};
    has Supplier $!latest-talks = Supplier.new;
    has Talkie::Store $!store;

    method TWEAK {
        with %.conf<storage> -> $storage {
            debug "Storing talks in $storage";
            $!store = Talkie::Store.new(dir => $storage);
            %!talks-by-id = $!store.retrieve-all;
            $!next-id = 1 + max 0, |%!talks-by-id.keys;
            $!store.start-writer($!latest-talks.Supply);
            # start whenever $!store.reader -> $talk {
            #     $!latest-talks.emit: $talk
            # }
        }
    }

    method add-talk(:$title,
        :$speaker,
        :$date,
        :$location=Nil,
        :$abstract=""
        --> Promise) {
        my $id = $!next-id++;
        my $new = Talk.new(:$id,
           :$title,
           :$speaker,
           :$abstract,
           :$location,
           :date( $date ?? Date.new($date) !! Nil)
        );
        %!talks-by-id{ $id } = $new;
        start $!latest-talks.emit($new);
    }

    method latest-talks(:$count = 10 --> Supply) {
        my @latest-existing = %!talks-by-id.values.sort(-*.id).head($count);
        supply {
            whenever $!latest-talks {
                .emit
            }
            .emit for @latest-existing;
        }
    }

    method retrieve($id) {
        if %!talks-by-id{$id}:exists {
            return %!talks-by-id{$id};
        }
    }
}
