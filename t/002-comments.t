use Talkie;
use Talkie::Talk;
use Test;
use Log::Async;

plan 8;

logger.add-tap: -> $m { diag $m<msg> if %*ENV<VERBOSE> }

my $talkie = Talkie.new;

lives-ok {
    $talkie.add-talk:
        :speaker<bob>,
        :title("a nice talk")
}, 'add a talk';

{
    my ($talk) = $talkie.latest-talks.head(1).list;
    is $talk.id, 1, 'got a talk';

    react {
        my $comments = $talk.latest-comments;
        ok $comments, 'getting comments';
        my $i = 1;
        whenever $comments -> $c {
            is $c<msg>, 'I agree with this talk.', 'got a comment' if $i==1;
            is $c<msg>, 'I do not agree with this talk.', 'got a comment' if $i==2;
            $i++;
            done if $c<user> eq 'b';
        }
        $talk.add-comment(:user<a>, msg => "I agree with this talk.");
        $talk.add-comment(:user<b>, msg => "I do not agree with this talk.");
    }
}

{
    my $talk = $talkie.retrieve(1);
    is $talk.id, 1, 'got talk again';
    my $talk-comments = $talk.latest-comments.head(2);
    is $talk-comments.list[0].<id>, 2, 'got second comment';
    is $talk-comments.list[1].<id>, 1, 'got first comment';
}

# vim: syn=perl6
