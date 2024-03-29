#!/usr/bin/env perl

use v5.14;
use Mojolicious::Lite;
use Config;
use Pod::Simple::Search;
use MetaCPAN::Pod::XHTML;

plugin Config => {file => 'pod-browser.conf', default => {}};

helper lib_dirs => sub {
    my $c = shift;
    my @dirs;

    if (my $dirs = $c->config->{search_dirs}) {
        push @dirs, @$dirs,
    }

    if (my $libdirs = $c->config->{libs_dirs}) {
        for my $libdir (@$libdirs) {
            push @dirs, glob("$libdir/*");
        }
    }

    return @dirs;
};

helper find_module => sub {
    my $c = shift;
    my $module = shift;
    Pod::Simple::Search->new->inc(0)->find($module, $c->lib_dirs);
};

get '/:module' => sub {
    my $c = shift;
    my $module = $c->stash('module');
    my ($path) = $c->find_module($module);

#    return $c->res->code(301) && $c->redirect_to("https://metacpan.org/pod/$module") unless $path && -r $path;
    my $parser = MetaCPAN::Pod::XHTML->new;
    $parser->$_('') for qw(html_header html_footer);
    $parser->anchor_items(1); # adds <a> to =items
    $parser->index(1);
    $parser->perldoc_url_prefix('/');
    $parser->output_string(\my $output);
    $parser->parse_file($path);
    $c->render(template => 'perldoc', content => $output);
};

app->start;

__DATA__

@@ perldoc.html.ep
<html>
    <head>
        <style>
            body {
                font-family: Ubuntu, sans-serif;
                width: 960px;
                margin: 1rem auto;
            }

            h1 {
                margin-left: -2rem;
            }

            h2,h3 {
                margin-left:  -1rem;
            }

            pre, code {
                background-color: rgb(214, 255, 223);
                font-family: Hack, monospace;
            }
            pre {
                padding: 1em;
                overflow-x: scroll;
            }
            code {
                padding: 0px 0.3em;
            }
            pre code {
                padding: 0;
            }

            p {
                line-height: 1.5;
            }
        </style>
    </head>
    <body>
        <%== $content %>
    </body>
</html>
