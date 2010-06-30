package TAP::Spec::TestSet;

use Moose;
use namespace::autoclean;

use TAP::Spec::Body ();
use TAP::Spec::Plan ();
use TAP::Spec::Header ();
use TAP::Spec::Footer ();

has 'body' => (
  is => 'rw',
  isa => 'TAP::Spec::Body',
  handles => {
    lines => 'lines',
    tests => 'tests',
    body_comments => 'comments',
  },
  required => 1,
);

has 'plan' => (
  is => 'rw',
  isa => 'TAP::Spec::Plan',
);

has 'header' => (
  is => 'rw',
  isa => 'TAP::Spec::Header',
  handles => { 
    header_comments => 'comments',
    version => 'version',
  },
  required => 1,
);

has 'footer' => (
  is => 'rw',
  isa => 'TAP::Spec::Footer',
  handles => {
    footer_comments => 'comments',
  },
  required => 1,
);

sub as_tap {
  my ($self) = @_;

  return $self->plan->as_tap()   .
         $self->header->as_tap() .
         $self->body->as_tap()   .
         $self->footer->as_tap();
}

__PACKAGE__->meta->make_immutable;
1;
1;
