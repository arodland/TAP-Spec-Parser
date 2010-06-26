package TAP::Spec::Parser;
use strict;
use warnings;

use Regexp::Grammars;

my $tap_grammar = qr{
# Main production
<testset>

# Definitions from first grammar section

# Testset         = Header (Plan Body / Body Plan) Footer
<token: testset> 
  <header> (?: <plan> <body> | <body> <plan> ) <footer>

# Header          = [Comments] [Version]
<token: header> 
  <comments>? <version>?

# Footer          = [Comments]
<token: footer> 
  <comments>?

# Body            = *(Comment / TAP-Line)
<token: body> 
  <[MATCH=_body_line]>*

<token: _body_line>
  <comment>
| <tap_line>

# TAP-Line        = Test-Result / Bail-Out
<token: tap_line> 
  <test_result>
| <bail_out>

# Version         = "TAP version" SP Version-Number EOL ; ie. "TAP version 13"
<token: version> 
  TAP version <.sp> <version_number> <.eol>

# Version-Number  = Positive-Integer
<token: version_number> 
  <positive_integer>

# Plan            = ( Plan-Simple / Plan-Todo / Plan-Skip-All ) EOL
<token: plan> 
  (?: <MATCH=plan_simple> | <MATCH=plan_todo> | <MATCH=plan_skip_all> ) <.eol>

# Plan-Simple     = "1.." Number-Of-Tests
<token: plan_simple>
  1.. <number_of_tests>

# Plan-Todo       = Plan-Simple "todo" 1*(SP Test-Number) ";"  ; Obsolete
<token: plan_todo>
  <plan_simple> todo (?: <.sp> <[test_number]> )+ ;

# Plan-Skip-All   = "1..0" SP "skip" SP Reason
<token: plan_skip_all>
  1..0 <.sp> skip <.sp> <reason>

# Reason          = String
<token: reason>
  <MATCH=string>

# Number-Of-Tests = 1*DIGIT               ; The number of tests contained in this stream
<token: number_of_tests>
  \d+

# Test-Number     = Positive-Integer      ; The sequence of a test result
<token: test_number>
  <MATCH=positive_integer>

# Test-Result     = Status [SP Test-Number] [SP Description]
#                    [SP "#" SP Directive [SP Reason]] EOL
<token: test_result>
  <status> (?: <.sp> <test_number> )? (?: <.sp> <description> )?
  (?: 
    <.sp> \# <.sp> <directive> 
    (?: <.sp> <reason>)? 
  )? <.eol>

# Status          = "ok" / "not ok"       ; Whether the test succeeded or failed
<token: status>
  ok
| not\ ok

# Description     = Safe-String           ; A description of this test.
<token: description>
  <MATCH=safe_string>

# Directive       = "SKIP" / "TODO"
<token: directive>
  SKIP
| TODO

# Bail-Out        = "Bail out!" [SP Reason] EOL
<token: bail_out>
  Bail out! (?: <.sp> <reason>)? <.eol>

# Comment         = "#" String EOL
<token: comment>
  \# <MATCH=string> <.eol>

# Comments        = 1*Comment
<token: comments>
  <[comment]>+

# EOL              = LF / CRLF             ; Specific to the system producing the stream
<token: eol>
  \n
| \r\n

# Safe-String      = 1*(%x01-09 %x0B-0C %x0E-22 %x24-FF)  ; UTF8 without EOL or "#"
<token: safe_string>
  [\x01-\x09\x0b-\x0c\x0e-\x22\x24-\xff]+

# String           = 1*(Safe-String / "#")                ; UTF8 without EOL
<token: string>
  (?: <.safe_string> | \# )+

# Positive-Integer = ("1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9") *DIGIT
<token: positive_integer>
  [1-9][0-9]*

# Because of BNF "SP" and because backslash-space in regex is ugly :)
<token: sp>
  \x20
}x;

sub parse_from_string {
  my ($self, $input) = @_;
  $input =~ /$tap_grammar/ or return;
  return \%/;
}

sub parse_from_handle {
  my ($self, $fh) = @_;
  my $data = do { local $/; <$fh> };
  return $self->parse_from_string($data);
}

1;
