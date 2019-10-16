# POD Browser

This is a super simple Mojolicious app whose sole purpose is to turn POD into
HTML. It does this by accepting a module name on the URL, finding it in `@INC`,
and putting the module through
[MetaCPAN::POD::XHTML](https://metacpan.org/pod/MetaCPAN::POD::XHTML).

## Installation

(You can also use [Docker](#Docker))

    cpanm --installdeps .

The distribution has a `cpanfile`, so you can install dependencies. Then run

    perl browser.pl daemon

To see options run

    perl browser.pl

or see [Mojolicious::Commands](https://metacpan.org/pod/Mojolicious::Commands)
for more information.

### Old Perls

If you have an old Perl there is a `perl-5.14` branch you can use.

If you have an older Perl than that, you have my sympathies, but you'll have to
edit the code yourself. I don't know what minimum Perl version the dependencies
require. (You might simply have to remove the line `use v5.14` but no promises.)

## Configuration

Copy `pod-browser.conf.example` to `pod-browser.conf` to use the basicest of
configurations, i.e. "Look in `@INC`".

### `search_dirs`

Each directory in this arrayref has the exact same semantics as a directory in
`@INC`, which is why it defaults to just `@INC`. Add a directory to this
arrayref to search a different lib dir for modules.

Like `@INC`, this is searched in order, and the first result used.

### `libs_dirs`

This arrayref contains *parent* directories of libs. The default is `/opt/libs`
because this should be an inert directory for most people. Globbing `/opt/libs/*`
should produce an array with the same semantics as the `search_dirs` config
option.

This was designed for the docker image, so that you can mount as many `lib` dirs
into `/opt/libs` as you wish, and the docker image will pick them up.

## Docker

There is a Dockerfile. You can create a docker image if you want.

    docker build -t podbrowser .

The mojo app runs on its default port of 3000. When you run it, add a directory
to `/opt/libs` to mimic the behaviour of `@INC`. Example:

    docker run -d --name podbrowser \
        -v /home/altreus/Pod-Cats/lib:/opt/libs/podcats \
        -p 3000:3000 \
        podbrowser

Now your POD browser is running on localhost:3000, and can see the modules
installed into the image from CPAN, and the modules in
/home/altreus/Pod-Cats/lib.
