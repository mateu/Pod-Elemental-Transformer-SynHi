#!/usr/bin/env perl
use v5.12.0;
use strict;
use warnings;
use utf8;
use charnames qw(:full);

use Encode ();
use Test::More;
use Pod::Elemental::Transformer::VimHTML;

my $open_q  = "\N{LEFT-POINTING DOUBLE ANGLE QUOTATION MARK}";
my $close_q = "\N{RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK}";

my $xform = Pod::Elemental::Transformer::VimHTML->new({
  use_standard_wrapper => 0,
});

my $decoded_input = qq{debug "${open_q}\$firstLine${close_q} is proper markdown ho, ho, ho";\n};
my $html = $xform->build_html($decoded_input, { filetype => 'perl' });

like(
  $html,
  qr/\Q$open_q\E.*\Q$close_q\E/s,
  'VimHTML preserves UTF-8 guillemets for decoded Perl text',
);

unlike(
  $html,
  qr/Â«|Â»/,
  'VimHTML does not leave mojibake markers behind',
);

my $octet_input = Encode::encode('utf-8', $decoded_input, Encode::FB_CROAK);
my $octet_html = $xform->build_html($octet_input, { filetype => 'perl' });

like(
  $octet_html,
  qr/\Q$open_q\E.*\Q$close_q\E/s,
  'VimHTML preserves guillemets for octet input',
);

done_testing;
