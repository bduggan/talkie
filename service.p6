use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Log::Async;
use JSON::Fast;

use Routes;
use Talkie;

logger.send-to($*ERR);

my $conf-file   = %*ENV<TALKIE_CONF> || "talkie.conf";
my %conf        = from-json($conf-file.IO.slurp) if $conf-file.IO.e;
my $talkie      = Talkie.new(:%conf);
my $application = routes($talkie);

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<TALKIE_HOST> || die("Missing TALKIE_HOST in environment"),
    port => %*ENV<TALKIE_PORT> || die("Missing TALKIE_PORT in environment"),
    :$application,
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<TALKIE_HOST>:%*ENV<TALKIE_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
