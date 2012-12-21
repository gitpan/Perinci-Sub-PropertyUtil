package Perinci::Sub::PropertyUtil;

use 5.010;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       declare_property
               );

our $VERSION = '0.01'; # VERSION

sub declare_property {
    my %args   = @_;
    my $name   = $args{name}   or die "Please specify property's name";
    my $schema = $args{schema} or die "Please specify property's schema";
    my $type   = $args{type};

    my $bs; # base schema (Rinci::metadata)
    my $ts; # per-type schema (Rinci::metadata::TYPE)
    my $bpp;
    my $tpp;

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
            or die "BUG: Schema structure changed (1)";
        $tpp->{$name}
            and die "Property '$name' is already declared in $type schema";
    }
    ($bpp // $tpp)->{$name} = $schema;

    {
        require Perinci::Sub::Wrapper;
        no strict 'refs';
        if ($args{wrapper}) {
            *{"Perinci::Sub::Wrapper::handlemeta_$name"} =
                sub { $args{wrapper}{meta} };
            *{"Perinci::Sub::Wrapper::handle_$name"} =
                $args{wrapper}{handler};
        } else {
            *{"Perinci::Sub::Wrapper::handlemeta_$name"} =
                sub { {} };
        }
    }
}

1;
# ABSTRACT: Utility routines for Perinci::Sub::Property::* modules


__END__
=pod

=head1 NAME

Perinci::Sub::PropertyUtil - Utility routines for Perinci::Sub::Property::* modules

=head1 VERSION

version 0.01

=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 declare_property

=head1 SEE ALSO

L<Perinci>

Perinci::Sub::Property::* modules.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

