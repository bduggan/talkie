use JSON::Fast;
use Log::Async;
use Markie;

class Talk {
    has Int $.id;
    has $.date;
    has Str:D $.speaker is required;
    has Str:D $.title is required;
    has Str $.abstract;
    has Str $.location;
    has Int $.next-comment-id = 1;
    has Hash %!comments-by-id{Int};
    has Supplier $!latest-comments = Supplier.new;

    method hash() {
        return %(
            :$.id,
            :$.title,
            :$.speaker,
            :$.abstract,
            :$.location,
            :$.date
        );
    }

    method add-comment(:$msg, :$user --> Promise) {
        my $id = $!next-comment-id++;
        debug "adding comment $id : $msg";
        my $new = %( :$msg, :$id, :$user, :html( md-to-html($msg) ), :timestamp(now) );
        %!comments-by-id{ $id } = $new;
        start $!latest-comments.emit: $new;
    }

    method latest-comments(:$count = 10 --> Supply) {
        my @latest-existing = %!comments-by-id.values.sort({ .<id> }).tail($count);
        supply {
           whenever $!latest-comments {
              .emit
            }
           .emit for @latest-existing;
        }
    }
}

