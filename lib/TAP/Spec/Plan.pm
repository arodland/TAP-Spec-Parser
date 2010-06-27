package TAP::Spec::Plan;

use Moose;
use namespace::autoclean;

use TAP::Spec::Plan::Simple ();
use TAP::Spec::Plan::Todo ();
use TAP::Spec::Plan::SkipAll ();

# Nothing here yet.

__PACKAGE__->meta->make_immutable;
1;
