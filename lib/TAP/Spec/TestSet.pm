package TAP::Spec::TestSet;
# ABSTRACT: A set of related TAP tests
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

has version => (
    is          => 'rw',
    isa         => 'Int',
    lazy        => 1,
    default     => sub {
        my $self = shift;

        if( my $v = $self->header->version ) {
            return $v->version_number;
        }
        else {
            return 12;
        }
    }
);

has 'header' => (
  is => 'rw',
  isa => 'TAP::Spec::Header',
  handles => { 
    header_comments => 'comments',
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

sub passed {
    my $self = shift;

    return '' unless $self->plan;
    my $expected = $self->plan->number_of_tests;

    my $lines = $self->body->lines;
    return '' unless @$lines == $expected;

    my $count = 1;
    for my $line (@$lines) {
        return '' unless $line->passed;
        return '' unless $line->number == $count++;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

