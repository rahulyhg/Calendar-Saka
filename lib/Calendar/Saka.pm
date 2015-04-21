package Calendar::Saka;

$Calendar::Saka::VERSION = '1.13';

=head1 NAME

Calendar::Saka - Interface to Indian Calendar.

=head1 VERSION

Version 1.13

=cut

use Data::Dumper;
use Term::ANSIColor::Markup;
use Date::Saka::Simple;
use Date::Utils qw(
    $SAKA_YEAR
    $SAKA_MONTH
    $SAKA_MONTHS
    $SAKA_DAYS

    julian_to_saka
    gregorian_to_julian
    days_in_saka_month_year
);

use Moo;
use namespace::clean;

use overload q{""} => 'as_string', fallback => 1;

has year  => (is => 'rw', isa => $SAKA_YEAR,  predicate => 1);
has month => (is => 'rw', isa => $SAKA_MONTH, predicate => 1);

sub BUILD {
    my ($self) = @_;

    unless ($self->has_year && $self->has_month) {
        my $date = Date::Saka::Simple->new;
        $self->year($date->year);
        $self->month($date->month);
    }
}

=head1 DESCRIPTION

Module  to  play  with Saka calendar  mostly  used  in  the South indian, Goa and
Maharashatra. It supports the functionality to add / minus days, months and years
to a Saka date. It can also converts Saka date to Gregorian/Julian date.

The  Saka eras are lunisolar calendars, and feature annual cycles of twelve lunar
months, each month divided into two phases:   the  'bright half' (shukla) and the
'dark half'  (krishna);  these correspond  respectively  to  the  periods  of the
'waxing' and the 'waning' of the moon. Thus, the  period beginning from the first
day  after  the new moon  and  ending on the full moon day constitutes the shukla
paksha or 'bright half' of the month the period beginning from the  day after the
full moon until &  including the next new moon day constitutes the krishna paksha
or 'dark half' of the month.

The  "year zero"  corresponds  to  78 BCE in the Saka calendar. The Saka calendar
begins with the month of Chaitra (March) and the Ugadi/Gudi Padwa festivals  mark
the new year.

Each  month  in  the Shalivahana  calendar  begins with the  'bright half' and is
followed by the 'dark half'.  Thus,  each  month of the Shalivahana calendar ends
with the no-moon day and the new month begins on the day after that.

A variant of the Saka Calendar was reformed & standardized as the Indian National
calendar in 1957. This official  calendar follows the Shalivahan Shak calendar in
beginning from the month of Chaitra and counting years with 78 CE being year zero.
It features a constant number of days in every month with leap years.Saka Calendar
for the month of Chaitra year 1937

    +----------------------------------------------------------------------------------------------------------------------+
    |                                                 Chaitra    [1937 BE]                                                 |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |       Ravivara |        Somvara |    Mangalavara |      Budhavara | Brahaspativara |      Sukravara |       Sanivara |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |              1 |              2 |              3 |              4 |              5 |              6 |              7 |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |              8 |              9 |             10 |             11 |             12 |             13 |             14 |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |             15 |             16 |             17 |             18 |             19 |             20 |             21 |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |             22 |             23 |             24 |             25 |             26 |             27 |             28 |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+
    |             29 |             30 |                                                                                    |
    +----------------+----------------+----------------+----------------+----------------+----------------+----------------+

=head1 SYNOPSIS

=head1 SAKA MONTHS

    +-------+-------------------------------------------------------------------+
    | Order | Name                                                              |
    +-------+-------------------------------------------------------------------+
    |   1   | Chaitra                                                           |
    |   2   | Vaisakha                                                          |
    |   3   | Jyaistha                                                          |
    |   4   | Asadha                                                            |
    |   5   | Sravana                                                           |
    |   6   | Bhadra                                                            |
    |   7   | Asvina                                                            |
    |   8   | Kartika                                                           |
    |   9   | Agrahayana                                                        |
    |  10   | Pausa                                                             |
    |  11   | Magha                                                             |
    |  12   | Phalguna                                                          |
    +-------+-------------------------------------------------------------------+

=head1 SAKA DAYS

    +---------+-----------+-----------------------------------------------------+
    | Weekday | Gregorian | Saka                                                |
    +---------+-----------+-----------------------------------------------------+
    |    0    | Sunday    | Ravivara                                            |
    |    1    | Monday    | Somvara                                             |
    |    2    | Tuesday   | Mangalavara                                         |
    |    3    | Wednesday | Budhavara                                           |
    |    4    | Thursday  | Brahaspativara                                      |
    |    5    | Friday    | Sukravara                                           |
    |    6    | Saturday  | Sanivara                                            |
    +---------+-----------+-----------------------------------------------------+

=head1 METHODS

=head2 current()

Returns current month of the Saka calendar.

    use strict; use warnings;
    use Calendar::Saka;

    print Calendar::Saka->new->current, "\n";

=cut

sub current {
    my ($self) = @_;

    my $date = Date::Saka::Simple->new;
    return _calendar($date->year, $date->month);
}

=head2 from_gregorian()

Returns saka month calendar in which the given gregorian date falls in.

    use strict; use warnings;
    use Calendar::Saka;

    print Calendar::Saka->new->from_gregorian(2015, 4, 19);

=cut

sub from_gregorian {
    my ($self, $year, $month, $day) = @_;

    return $self->from_julian(gregorian_to_julian($year, $month, $day));
}

=head2 from_julian($julian_date)

Returns saka month calendar in which the given julian date falls in.

    use strict; use warnings;
    use Calendar::Saka;

    print Calendar::Saka->new->from_julian(2457102.5), "\n";

=cut

sub from_julian {
    my ($self, $julian) = @_;

    my ($year, $month, $day) = julian_to_saka($julian);
    return _calendar($year, $month);
}

sub as_string {
    my ($self) = @_;

    return _calendar($self->year, $self->month);
}

#
#
# PRIVATE METHODS

sub _calendar {
    my ($year, $month) = @_;

    my $date = Date::Saka::Simple->new({ year => $year, month => $month, day => 1 });
    my $start_index = $date->day_of_week;
    my $days = days_in_saka_month_year($month, $year);

    my $line1 = '<blue><bold>+' . ('-')x118 . '+</bold></blue>';
    my $line2 = '<blue><bold>|</bold></blue>' .
                (' ')x49 . '<yellow><bold>' .
                sprintf("%-10s [%4d BE]", $SAKA_MONTHS->[$month], $year) .
                '</bold></yellow>' . (' ')x49 . '<blue><bold>|</bold></blue>';
    my $line3 = '<blue><bold>+';

    for(1..7) {
        $line3 .= ('-')x(16) . '+';
    }
    $line3 .= '</bold></blue>';

    my $line4 = '<blue><bold>|</bold></blue>' .
                join("<blue><bold>|</bold></blue>", @$SAKA_DAYS) .
                '<blue><bold>|</bold></blue>';

    my $calendar = join("\n", $line1, $line2, $line3, $line4, $line3)."\n";
    if ($start_index % 7 != 0) {
        $calendar .= '<blue><bold>|</bold></blue>                ';
        map { $calendar .= "                 " } (2..($start_index %= 7));
    }
    foreach (1 .. $days) {
        $calendar .= sprintf("<blue><bold>|</bold></blue><cyan><bold>%15d </bold></cyan>", $_);
        if ($_ != $days) {
            $calendar .= "<blue><bold>|</bold></blue>\n" . $line3 . "\n"
                unless (($start_index + $_) % 7);
        }
        elsif ($_ == $days) {
            my $x = 7 - (($start_index + $_) % 7);
            if (($x >= 2) && ($x != 7)) {
                $calendar .= '<blue><bold>|</bold></blue>                ';
                map { $calendar .= ' 'x17 } (1..$x-1);
            }
        }
    }

    $calendar = sprintf("%s<blue><bold>|</bold></blue>\n%s\n", $calendar, $line3);

    return Term::ANSIColor::Markup->colorize($calendar);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Calendar-Saka>

=head1 BUGS

Please  report any bugs or feature requests to C<bug-calendar-saka at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Saka>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Saka

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Saka>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Saka>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Saka>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Saka/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2011 - 2015 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Calendar::Saka
