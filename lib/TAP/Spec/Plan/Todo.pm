package TAP::Spec::Plan::Todo;
use Moose;
use namespace::autoclean;
extends 'TAP::Spec::Plan::Simple';

has 'skipped_tests' => (
  is => 'rw',
  isa => 'ArrayRef',
  required => 1,
);

around 'as_tap' => sub {
  my ($self, $inner) = @_;

  my $tap = $inner->();
  my $append = " todo";
  $append .= " $_" for @{ $self->skipped_tests };
  $tap =~ s/$/$append/;
  return $tap;
};

__PACKAGE__->meta->make_immutable;
1;
