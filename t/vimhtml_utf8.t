#!/usr/bin/env perl
use v5.12.0;
use strict;
use warnings;
use utf8;
use charnames qw(:full);

use Encode ();
use Test::More;
use Pod::Elemental::Document;
use Pod::Elemental::Element::Pod5::Data;
use Pod::Elemental::Element::Pod5::Region;
use Pod::Elemental::Element::Pod5::Verbatim;
use Pod::Elemental::Transformer::VimHTML;

my $open_q  = "\N{LEFT-POINTING DOUBLE ANGLE QUOTATION MARK}";
my $close_q = "\N{RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK}";

sub transform_verbatim {
  my ($content) = @_;

  my $para = Pod::Elemental::Element::Pod5::Verbatim->new({ content => $content });
  my $doc  = Pod::Elemental::Document->new({ children => [$para] });
  my $xform = Pod::Elemental::Transformer::VimHTML->new({
    use_standard_wrapper => 0,
  });

  $xform->transform_node($doc);

  my $child = $doc->children->[0];
  isa_ok($child, 'Pod::Elemental::Element::Pod5::Region', 'verbatim transformed into html region');

  return $child->children->[0]->content;
}

my $decoded_input = qq{#!vim perl\n\n  debug "${open_q}\$firstLine${close_q} is proper markdown ho, ho, ho";\n};
my $html = transform_verbatim($decoded_input);

like(
  $html,
  qr/\Q$open_q\E.*\Q$close_q\E/s,
  'transformer preserves UTF-8 guillemets for decoded Perl text',
);

unlike(
  $html,
  qr/Â«|Â»/,
  'transformer does not leave mojibake markers behind',
);

my $octet_input = Encode::encode('utf-8', $decoded_input, Encode::FB_CROAK);
my $octet_html = transform_verbatim($octet_input);

like(
  $octet_html,
  qr/\Q$open_q\E.*\Q$close_q\E/s,
  'transformer preserves guillemets for octet input',
);

done_testing;
