use Talkie;
use Log::Async;
use Test;

plan 6;

logger.add-tap: { diag .<msg> if %*ENV<VERBOSE> }

my $talkie = Talkie.new;

lives-ok { $talkie.add-talk(
    :speaker<bob>,
    title => "Life, the Universe and Everything") }, 'add talk';
lives-ok { $talkie.add-talk(
    :speaker<alice>,
    title => "How to Train your Dragon") }, 'add talk';

given $talkie.latest-talks.head(2).list -> @talks {
    is @talks[0].title, 'How to Train your Dragon', '2nd talk is first';
    is @talks[0].id, 2, '2nd talk is first';
    is @talks[1].title, 'Life, the Universe and Everything', '1st talk is second';
}

await $talkie.add-talk( :speaker<alice>, :title<waiting> );

react {
    whenever $talkie.latest-talks.skip(3).head(1) {
        is .title, "The Secret of My Success", 'got latest talk';
    }
    $talkie.add-talk:
        speaker => "sam",
        title => "The Secret of My Success";
}
