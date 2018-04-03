use Talkie;
use Test;
use Log::Async;

logger.add-tap: { diag .<msg> if %*ENV<VERBOSE> }

my $storage will leave {
    .unlink for .IO.dir; .IO.rmdir
 }
 = $*TMPDIR.child("talkie-data.$*PID").Str;
mkdir $storage;

my $talkie = Talkie.new: conf => { :$storage }

ok 1, 'todo';

done-testing;
