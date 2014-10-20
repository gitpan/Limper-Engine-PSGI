use Test::More tests => 8;
use Limper::Engine::PSGI;
use Limper;
use strict;
use warnings;

SKIP: {
    eval { require Plack::Test };
    skip "Plack::Test not installed", 8 if $@;

    eval { require HTTP::Request };
    skip "HTTP::Request not installed", 8 if $@;

    my $generic = sub { 'yay' };

    get '/' => $generic;
    post '/' => $generic;

    post qr{^/foo/} => sub {
    	status 202, 'whatevs';
        headers Foo => 'bar', Foo => 'buzz', 'Content-Type' => 'text/whee';
        'you posted something: ' . request->{body};
    };

    my $app = limp;

    my $test = Plack::Test->create($app);

    my $res = $test->request(HTTP::Request->new(GET => '/fizz'));
    is $res->status_line, '404 Not Found', '404 status';
    is $res->content, 'This is the void', '404 body';

    $res = $test->request(HTTP::Request->new(HEAD => '/'));
    is $res->status_line, '200 OK', '200 status';
    is $res->content, '', 'head no body';

    $res = $test->request(HTTP::Request->new(POST => '/foo/bar', undef, 'foo=bar'));
    is $res->status_line, '202 Accepted', 'post status';
    is $res->content, 'you posted something: foo=bar', 'post body';
    is $res->header('Foo'), 'bar, buzz', 'Foo: bar';
    is $res->header('Content-Type'), 'text/whee', 'Content-Type: text/whee';

};
