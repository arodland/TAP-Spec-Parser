package TAP::Spec::JunkLine;
# ABSTRACT: A line of non-TAP data in a TAP stream
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;

=attr text

B<Required>: the comment text.

=cut

has 'text' => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

=method $comment->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  return "## JUNK LINE: " . $self->text . "\n";
}

__PACKAGE__->meta->make_immutable;
