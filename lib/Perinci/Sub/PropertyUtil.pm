package Perinci::Sub::PropertyUtil;

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       declare_property
               );

our $VERSION = '0.02'; # VERSION

sub declare_property {
    my %args   = @_;
    my $name   = $args{name}   or die "Please specify property's name";
    my $schema = $args{schema} or die "Please specify property's schema";
    my $type   = $args{type};

    $name =~ m!\A((result)/)?\w+\z! or die "Invalid property name";

    my $bs; # base schema (Rinci::metadata)
    my $ts; # per-type schema (Rinci::metadata::TYPE)
    my $bpp;
    my $tpp;

    # insert the property's schema into Rinci::Schema's data
    {
        # XXX currently we skip result/*
        last if $name =~ m!\Aresult/!;

        require Rinci::Schema;
        $bs = $Rinci::Schema::base;
        $bpp = $bs->[1]{"keys"}
            or die "BUG: Schema structure changed (1)";
        $bpp->{$name}
            and die "Property '$name' is already declared in base schema";
        if ($type) {
            if ($type eq 'function') {
                $ts = $Rinci::Schema::function;
            } elsif ($type eq 'variable') {
                $ts = $Rinci::Schema::variable;
            } elsif ($type eq 'package') {
                $ts = $Rinci::Schema::package;
            } else {
                die "Unknown/unsupported property type: $type";
            }
            $tpp = $ts->[1]{"[merge+]keys"}
                or die "BUG: Schema structure changed (2)";
            $tpp->{$name}
                and die "Property '$name' is already declared in $type schema";
        }
        ($bpp // $tpp)->{$name} = $schema;
    }

    # install wrapper
    {
        require Perinci::Sub::Wrapper;
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        if ($args{wrapper}) {
            *{"Perinci::Sub::Wrapper::handlemeta_$n"} =
                sub { $args{wrapper}{meta} };
            *{"Perinci::Sub::Wrapper::handle_$n"} =
                $args{wrapper}{handler};
        } else {
            *{"Perinci::Sub::Wrapper::handlemeta_$n"} =
                sub { {} };
        }
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

version 0.02

=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 declare_property

=head1 SEE ALSO

L<Perinci>

Perinci::Sub::Property::* modules.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Sub-PropertyUtil>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Perinci-Sub-PropertyUtil>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Sub-PropertyUtil>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
