package TAP::Spec::TestSet;
# ABSTRACT: A set of related TAP tests
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;

use TAP::Spec::Body ();
use TAP::Spec::Plan ();
use TAP::Spec::Header ();
use TAP::Spec::Footer ();

=attr body

B<Required>: The testset body (contains the test results, as well as any
bail-outs, and any comment lines outside of the headers). Is a 
L<TAP::Spec::Body>.

=cut

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

=attr plan

B<Required>: The test plan. Is a L<TAP::Spec::Plan>.

=cut

has 'plan' => (
  is => 'rw',
  isa => 'TAP::Spec::Plan',
);

=attr version

B<Computed>: The TAP spec version. If a version is present in the header,
it is used, otherwise version 12 is assumed.

=cut

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

=attr header

B<Required>: The TAP header. Is a L<TAP::Spec::Header>.

=cut

has 'header' => (
  is => 'rw',
  isa => 'TAP::Spec::Header',
  handles => { 
    header_comments => 'comments',
  },
  required => 1,
);

=attr footer

B<Required>: The TAP footer. Is a L<TAP::Spec::Footer>.

=cut

has 'footer' => (
  is => 'rw',
  isa => 'TAP::Spec::Footer',
  handles => {
    footer_comments => 'comments',
  },
  required => 1,
);

=method $testset->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  return $self->plan->as_tap()   .
         $self->header->as_tap() .
         $self->body->as_tap()   .
         $self->footer->as_tap();
}

=method $testset->passed

Whether the testset is considered to have passed. A testset passes if a plan
was found, and the number of tests executed matches the number of tests planned,
and all tests are passing.

=cut

sub passed {
    my $self = shift;

    return '' unless $self->plan;
    my $expected = $self->plan->number_of_tests;

    my @tests = $self->tests;
    return '' unless @tests == $expected;

    my $count = 1;
    for my $test (@tests) {
        return '' unless $test->passed;
        return '' unless $test->number == $count++;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
