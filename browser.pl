#!/usr/bin/env perl

use v5.24;
use Mojolicious::Lite;
use Config;
use experimental 'signatures';
use Pod::Simple::Search;
use MetaCPAN::Pod::XHTML;

plugin Config => {file => 'doc-browser.conf', default => {}};

helper lib_dirs => sub ($c) {
    my @dirs;

    if (my $dirs = $c->config->{search_dirs}) {
        push @dirs, @$dirs,
    }

    if (my $libdirs = $c->config->{libs_dirs}) {
        for my $libdir (@$libdirs) {
            push @dirs, glob("$libdir/*");
        }
    }

    $c->log->debug("[ $_ ]") for @dirs;

    return @dirs;
};

helper find_module => sub ($c, $module) {
    Pod::Simple::Search->new->inc(0)->find($module, $c->lib_dirs);
};

get '/:module' => sub ($c) {
    my $module = $c->stash('module');
    my ($path) = $c->find_module($module);

#    return $c->res->code(301) && $c->redirect_to("https://metacpan.org/pod/$module") unless $path && -r $path;
    my $parser = MetaCPAN::Pod::XHTML->new;
    $parser->perldoc_url_prefix('/');
    $parser->output_string(\my $output);
    $parser->parse_file($path);
    $c->render(text => $output);
};

app->start;
