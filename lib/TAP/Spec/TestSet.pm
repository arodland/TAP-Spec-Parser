package TAP::Spec::TestSet;

use Moose;
use namespace::autoclean;

has 'body' => (
  is => 'rw',
  isa => 'TAP::Spec::Body',
  handles => {
    lines => 'lines',
    tests => 'tests',
    body_comments => 'comments',
  },
);

has 'header' => (
  is => 'rw',
  isa => 'TAP::Spec::Header',
  handles => { 
    header_comments => 'comments',
    version => 'version',
  },
);

has 'footer' => (
  is => 'rw',
  isa => 'TAP::Spec::Footer',
  handles => {
    footer_comments => 'comments',
  },
);

1;
