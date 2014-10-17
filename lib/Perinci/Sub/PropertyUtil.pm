package Perinci::Sub::PropertyUtil;

our $DATE = '2014-10-17'; # DATE
our $VERSION = '0.07'; # VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       declare_property
               );

sub declare_property {
    my %args   = @_;
    my $name   = $args{name}   or die "Please specify property's name";
    my $schema = $args{schema} or die "Please specify property's schema";
    my $type   = $args{type};

    $name =~ m!\A((result|args/\*)/)?\w+\z! or die "Invalid property name";

    # insert the property's schema into Sah::Schema::Rinci
    {
        require Sah::Schema::Rinci;
        my $p = $Sah::Schema::Rinci::SCHEMAS{rinci_function}[1]{_prop}
            or die "BUG: Schema structure changed (1)";

        my $n;
        if ($name =~ m!\Aresult/(.+)!) {
            $n = $1;
            $p = $p->{result}{_prop}
                or die "BUG: Schema structure changed (2)";
        } elsif ($name =~ m!\Aargs/\*/(.+)!) {
            $n = $1;
            $p = $p->{args}{_value_prop}
                or die "BUG: Schema structure changed (3)";
        } else {
            $n = $name;
        }

        $p->{$n}
            and die "Property '$name' is already declared in schema";
        # XXX we haven't injected $schema
        $p->{$n} = {};
    }

    # install wrapper handler
    if ($args{wrapper}) {
        no strict 'refs';
        my $n = $name; $n =~ s!(/\*)?/!__!g;
        *{"Perinci::Sub::Wrapper::handlemeta_$n"} =
            sub { $args{wrapper}{meta} };
        *{"Perinci::Sub::Wrapper::handle_$n"} =
            $args{wrapper}{handler};
    }

    # install Perinci::CmdLine help handler
    if ($args{cmdline_help}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::CmdLine::help_hookmeta_$n"} =
            sub { $args{cmdline_help}{meta} };
        *{"Perinci::CmdLine::help_hook_$n"} =
            $args{cmdline_help}{handler};
    }

    # install Perinci::Sub::To::POD help hook
    if ($args{pod}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::Sub::To::POD::hookmeta_$n"} =
            sub { $args{pod}{meta} };
        *{"Perinci::Sub::To::POD::hook_$n"} =
            $args{pod}{handler};
    }
}

1;
# ABSTRACT: Utility routines for Perinci::Sub::Property::* modules

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Sub::PropertyUtil - Utility routines for Perinci::Sub::Property::* modules

=head1 VERSION

This document describes version 0.07 of Perinci::Sub::PropertyUtil (from Perl distribution Perinci-Sub-PropertyUtil), released on 2014-10-17.

=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 declare_property

=head1 SEE ALSO

L<Perinci>

Perinci::Sub::Property::* modules.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Sub-PropertyUtil>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Perinci-Sub-PropertyUtil>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Sub-PropertyUtil>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
