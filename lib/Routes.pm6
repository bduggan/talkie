use Cro::HTTP::Router;
use Cro::HTTP::Router::WebSocket;
use Cro::HTTP::Client;
use JSON::Fast;
use Talkie;
use Markie;
use Log::Async;

sub routes(Talkie $talkie) is export {
    my $client_id = $talkie.conf<github><client_id>;
    my $client_secret = $talkie.conf<github><client_secret>;

    route {
        after {
            header 'Access-Control-Allow-Origin', '*';
        }

        $*CRO-ROUTE-SET.add-handler: 'OPTIONS', -> {
            header 'Allow', <OPTIONS GET HEAD POST>.join(', ');
            content 'text/plain', '';
        }

        post -> 'login' {
            request-body -> ( :$code ) {
                my $resp = await Cro::HTTP::Client.post:
                    'https://github.com/login/oauth/access_token',
                        headers => [
                            content-type => 'application/json',
                            accept => 'application/json',
                        ],
                        body => {
                            :$client_id, :$client_secret, :$code
                        };
                my $json = await $resp.body;
                content 'application/json', $json
            }
        }

        get -> {
            static 'static/index.html';
            response.remove-header('Content-type');
            header 'Content-type', 'text/html; charset="utf-8"';
        }

        get -> 'js', *@path {
            static 'static/js', @path
        }

        get -> 'css', *@path {
            static 'static/css', @path
        }

        post -> 'talks' {
            request-body -> %json is required {
                $talkie.add-talk(|%json);
                response.status = 204;
            }
        }

        get -> 'talk', UInt:D $id {
            with $talkie.retrieve($id) -> $talk {
                content 'application/json', %$talk;
            } else {
                not-found;
            }
        }

        get -> 'latest-talks' {
            web-socket :json, -> $incoming {
                my $supply = $talkie.latest-talks;
                supply whenever $supply -> $talk {
                # swallows exceptions in latest-talks
                # supply whenever $talkie.latest-talks -> $talk {
                    emit %(
                        :WS_ACTION,
                        action => %( :type<LATEST_TALK>, talk => %$talk )
                    )
                }
            }
        }

        get sub ('latest-comments', UInt:D $id) {
            my $talk = $talkie.retrieve($id) or return not-found;
            web-socket :json, {
                my $supply = $talk.latest-comments;
                supply whenever $supply -> $comment {
                   emit %(
                       :WS_ACTION,
                       action => %( :type<LATEST_COMMENT>, :$comment )
                   )
                }
            }
        }

        post sub ('talk', Int:D $id, 'comments') {
            my $talk = $talkie.retrieve($id) or return not-found;
            request-body -> (
                Str:D :$msg where .chars > 0,
                Str:D :$user,
            ) {
                $talk.add-comment(:$msg, :$user);
            }
            content 'application/json', %( :status<ok> )
        }
    }
}
