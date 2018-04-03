use Talkie;
use Talkie::Talk;
use Test;
use Log::Async;

plan 6;

logger.add-tap: -> $m { diag $m<msg> if %*ENV<VERBOSE> }

my $talkie = Talkie.new;

lives-ok {
    $talkie.add-talk:
        :speaker<bob>,
        :title("a nice talk")
}, 'add a talk';

my ($talk) = $talkie.latest-talks.head(1).list;
is $talk.id, 1, 'got a talk';

react {
    my $comments = $talk.latest-comments;
    ok $comments, 'getting comments';
    whenever $comments -> $c {
        is $c<msg>, 'I agree with this talk.', 'got a comment';
        done;
    }
    $talk.add-comment(msg => "I agree with this talk.");
}

my $again = $talkie.retrieve(1);
is $again.id, 1, 'got talk again';
my $again-comments = $again.latest-comments.head(1);
is $again-comments.list[0].<id>, 1, 'got first comment again';

# vim: syn=perl6
