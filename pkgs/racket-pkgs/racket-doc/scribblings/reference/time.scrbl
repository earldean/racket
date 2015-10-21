#lang scribble/doc
@(require "mz.rkt" (for-label racket/date))

@title[#:tag "time"]{Time}

@defproc[(current-seconds) exact-integer?]{

Returns the current time in seconds since midnight UTC, January 1,
1970.}


@defproc[(current-inexact-milliseconds) real?]{

Returns the current time in milliseconds since midnight UTC, January
1, 1970. The result may contain fractions of a millisecond.

@examples[(eval:alts
(current-inexact-milliseconds)
1289513737015.418
)]

In this example, @racket[1289513737015] is in milliseconds and @racket[418]
is in microseconds.}


@defproc[(seconds->date [secs-n real?]
                        [local-time? any/c #t])
         date*?]{

Takes @racket[secs-n], a platform-specific time in seconds returned by
@racket[current-seconds], @racket[file-or-directory-modify-seconds],
or 1/1000th of @racket[current-inexact-milliseconds], and returns an
instance of the @racket[date*] structure type. Note that
@racket[secs-n] can include fractions of a second. If @racket[secs-n]
is too small or large, the @exnraise[exn:fail].

The resulting @racket[date*] reflects the time according to the local
time zone if @racket[local-time?] is @racket[#t], otherwise it
reflects a date in UTC.}

@defstruct[date ([second (integer-in 0 60)]
                 [minute (integer-in 0 59)]
                 [hour (integer-in 0 23)]
                 [day (integer-in 1 31)]
                 [month (integer-in 1 12)]
                 [year exact-integer?]
                 [week-day (integer-in 0 6)]
                 [year-day (integer-in 0 365)]
                 [dst? boolean?]
                 [time-zone-offset exact-integer?])
                #:inspector #f]{

Represents a date. The @racket[_second] field reaches @racket[60] only
for leap seconds. The @racket[week-day] field is @racket[0] for
Sunday, @racket[1] for Monday, etc. The @racket[year-day] field is
@racket[0] for January 1, @racket[1] for January 2, @|etc|; the
@racket[year-day] field reaches @racket[365] only in leap years.

The @racket[dst?] field is @racket[#t] if the date reflects a
daylight-saving adjustment. The @racket[time-zone-offset] field
reports the number of seconds east of UTC (GMT) for the current time zone
(e.g., Pacific Standard Time is @racket[-28800]), including any
daylight-saving adjustment (e.g., Pacific Daylight Time is
@racket[-25200]). When a @racket[date] record is generated by
@racket[seconds->date] with @racket[#f] as the second argument, then
the @racket[dst?] and @racket[time-zone-offset] fields are
@racket[#f] and @racket[0], respectively.

The @racket[date] constructor accepts any value for @racket[dst?]
and converts any non-@racket[#f] value to @racket[#t].

The value produced for the @racket[time-zone-offset] field tends to be
sensitive to the value of the @envvar{TZ} environment variable,
especially on Unix platforms; consult the system documentation
(usually under @tt{tzset}) for details.

See also the @racketmodname[racket/date] library.}


@defstruct[(date* date) ([nanosecond (integer-in 0 999999999)]
                         [time-zone-name (and/c string? immutable?)])]{

Extends @racket[date] with nanoseconds and a time zone name, such as
@racket["MDT"], @racket["Mountain Daylight Time"], or @racket["UTC"].

When a @racket[date*] record is generated by @racket[seconds->date]
with @racket[#f] as the second argument, then the
@racket[time-zone-name] field is @racket["UTC"].

The @racket[date*] constructor accepts a mutable string for
@racket[time-zone-name] and converts it to an immutable one.}


@defproc[(current-milliseconds) exact-integer?]{

Like @racket[current-inexact-milliseconds], but coerced to a
@tech{fixnum} (possibly negative). Since the result is a
@tech{fixnum}, the value increases only over a limited (though
reasonably long) time on a 32-bit platform.}


@defproc[(current-process-milliseconds [thread (or/c thread? #f)]) 
         exact-integer?]{

Returns an amount of processor time in @tech{fixnum} milliseconds
that has been consumed by the Racket process on the underlying
operating system. (On @|AllUnix|, this includes both user and
system time.)  If @racket[thread] is @racket[#f], the reported time
is for all Racket threads, otherwise the result is specific to the
time while @racket[thread] ran.
The precision of the result is platform-specific, and
since the result is a @tech{fixnum}, the value increases only over a
limited (though reasonably long) time on a 32-bit platform.}


@defproc[(current-gc-milliseconds) exact-integer?]{

Returns the amount of processor time in @tech{fixnum} milliseconds
that has been consumed by Racket's garbage collection so far. This
time is a portion of the time reported by
@racket[(current-process-milliseconds)], and is similarly limited.}


@defproc[(time-apply [proc procedure?]
                     [lst list?])
         (values list?
                 exact-integer?
                 exact-integer?
                 exact-integer?)]{

Collects timing information for a procedure application.

Four values are returned: a list containing the result(s) of applying
@racket[proc] to the arguments in @racket[lst], the number of milliseconds of
CPU time required to obtain this result, the number of ``real'' milliseconds
required for the result, and the number of milliseconds of CPU time (included
in the first result) spent on garbage collection.

The reliability of the timing numbers depends on the platform. If
multiple Racket threads are running, then the reported time may
include work performed by other threads.}

@defform[(time body ...+)]{

Reports @racket[time-apply]-style timing information for the
evaluation of @racket[expr] directly to the current output port.  The
result is the result of  the last @racket[body].}

@; ----------------------------------------------------------------------

@section[#:tag "date-string"]{Date Utilities}

@note-lib-only[racket/date]

@defproc[(current-date) date*?]{

An abbreviation for @racket[(seconds->date (* 0.001 (current-inexact-milliseconds)))].}

@defproc[(date->string [date date?] [time? any/c #f]) string?]{

Converts a date to a string. The returned string contains the time of
day only if @racket[time?]. See also @racket[date-display-format].}


@defparam[date-display-format format (or/c 'american
                                           'chinese
                                           'german
                                           'indian
                                           'irish
                                           'iso-8601
                                           'rfc2822
                                           'julian)]{

Parameter that determines the date string format. The initial format
is @racket['american].}

@defproc[(date->seconds [date date?] [local-time? any/c #t]) exact-integer?]{
Finds the representation of a date in platform-specific seconds.
If the platform cannot represent the specified date,
@exnraise[exn:fail].

The @racket[week-day], @racket[year-day] fields of @racket[date] are
ignored.  The @racket[dst?] and @racket[time-zone-offset] fields of
@racket[date] are also ignored; the date is assumed to be in local
time by default or in UTC if @racket[local-time?] is @racket[#f].}

@defproc[(date*->seconds [date date?] [local-time? any/c #t]) real?]{
Like @racket[date->seconds], but returns an exact number that can
include a fraction of a second based on @racket[(date*-nanosecond
date)] if @racket[date] is a @racket[date*] instance.}

@defproc[(find-seconds [second (integer-in 0 61)]
                       [minute (integer-in 0 59)]
                       [hour (integer-in 0 23)]
                       [day (integer-in 1 31)]
                       [month (integer-in 1 12)]
                       [year exact-nonnegative-integer?]
                       [local-time? any/c #t])
         exact-integer?]{

Finds the representation of a date in platform-specific seconds. The
arguments correspond to the fields of the @racket[date] structure---in
local time by default or UTC if @racket[local-time?] is
@racket[#f]. If the platform cannot represent the specified date, an
error is signaled, otherwise an integer is returned.}


@defproc[(date->julian/scalinger [date date?]) exact-integer?]{

Converts a date structure (up to 2099 BCE Gregorian) into a Julian
date number. The returned value is not a strict Julian number, but
rather Scalinger's version, which is off by one for easier
calculations.}


@defproc[(julian/scalinger->string [date-number exact-integer?])
         string?]{

Converts a Julian number (Scalinger's off-by-one version) into a
string.}
