# SKHScal

Dynamic calendar for schools on an AB block schedule.

Command line scripts to generate **[iCalendar][] ([RFC5545][] and [RFC7986][])** entries for A and B days for a school on a block schedule. The file can be imported directly or it can be hosted on the web (e.g., GitHub Pages) as a subscription.

[icalendar]: <https://en.wikipedia.org/wiki/ICalendar>
[rfc5545]: <https://icalendar.org/RFC-Specifications/iCalendar-RFC-5545/>
[rfc7986]: <https://icalendar.org/RFC-Specifications/iCalendar-RFC-7986/>

## Files

* **skdays.rb:** generates calendar
* **snowday.rb:** adds snowday(s) to list of days off this year

## Usage

Setup instructions are in [docs/README.md][instructions].

[instructions]: <docs/README.md>

## Validation

[iCalendar Validator](https://icalendar.org/validator.html)

## Automation

[StackOverflow: How do I create a link to add an entry to a calendar?
](https://stackoverflow.com/questions/5831877/how-do-i-create-a-link-to-add-an-entry-to-a-calendar) - might be helpful for finding information on creating a "click to subscribe" link.
