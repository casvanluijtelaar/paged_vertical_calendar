## 1.1.5
* fix potential infinite loader when minDate & initialDate are in the same month
## 1.1.4
* reimplement ScrollPhysics after it was removed by 1.0.6

## 1.1.3
* ability to start the week on Sunday. Thanks to [dmitry-kotorov](https://github.com/casvanluijtelaar/paged_vertical_calendar/pull/20)

## 1.1.2
* updated dependencies
* removed unnecessary `intl` dependency 

## 1.1.1
* reverted scrollcontroller to 1.0.4 implementation after it was changed in 1.0.6

## 1.1.0
* update to Flutter 3.0!!!
* **BREAKING**: in order to better reflect the bi-directional pagination, `startDate` & `endDate`have been renamed to `minDate` & `maxDate`
* **BREAKING**: `onPaginationComplete` will now return a `PaginationDirection` to indicate if `minDate` or `maxDate` has been reached

## 1.0.6
* allow for bi-directional pagination. thanks to [desmeit](https://github.com/casvanluijtelaar/paged_vertical_calendar/pull/13)
* adds initiaDate parameter that sets the starting location of the calendar view.
## 1.0.5

* typo (woops!)

## 1.0.4

* exposed scrollController
* fixed month generation bug [#10](https://github.com/casvanluijtelaar/paged_vertical_calendar/pull/10)

## 1.0.3

* added ability to set custom scrollPhysics [#8](https://github.com/casvanluijtelaar/paged_vertical_calendar/pull/8)
* updates dependencies
* minor bug fixes

## 1.0.2

* updated pubspec to fix metadata issues

## 1.0.1

* Fixed a bug where overlapping weeks weren't calculated correctly resulting in missing days.
* added web & windows build to example

## 1.0.0

* released nullsafety


## 1.0.0-nullsafety

* Migrated to nullsafety


## 0.0.1

* Initial release
