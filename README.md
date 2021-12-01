# :calendar: Paged Vertical Calendar :calendar:

[![Pub](https://img.shields.io/pub/v/paged_vertical_calendar)](https://pub.dartlang.org/packages/paged_vertical_calendar)
[![Pub](https://img.shields.io/github/stars/casvanluijtelaar/paged_vertical_calendar)](https://github.com/casvanluijtelaar/paged_vertical_calendar)
[![Pub](https://img.shields.io/github/last-commit/casvanluijtelaar/paged_vertical_calendar)](https://github.com/casvanluijtelaar/paged_vertical_calendar)

<p align="center">
    A simple paginated framework for implementing calendar based interfaces.
</p>


<p align="center">
  <img src="https://github.com/casvanluijtelaar/paged_vertical_calendar/blob/master/assets/style_comp.gif?raw=true" alt="gif showing of package customizability" width="200"/>
  <img src="https://github.com/casvanluijtelaar/paged_vertical_calendar/blob/master/assets/range_comp.gif?raw=true" alt="gif showing dat range picker example" width="200"/>
  <img src="https://github.com/casvanluijtelaar/paged_vertical_calendar/blob/master/assets/paged_comp.gif?raw=true" alt="gif showing paged data example" width="200"/>
<p\>

## :hammer: How it works 
`paged_vertical_calendar` is a very minimalistic framework that automatically loads months based on scoll behavior. It provides many useful callbacks to implement your own calendar interactions and builders to customize the calendar as much as you want. Check the example for several implementations like date range selection and paginated data visualisation.

`PagedVerticalCalendar` has no required parameters and can be dropped in anywhere providing it has a fixed height.

```dart
Scaffold(
  body: PagedVerticalCalendar(),
);
```
## :loudspeaker: Callbacks

Several callback are provided to facilitate easy implementation of any calendar interactions

```dart
PagedVerticalCalendar(
  invisibleMonthsThreshold: 1,
  onMonthLoaded: (year, month) {
    // on month widget load 
  },
  onDayPressed: (value) {
    // on day widget pressed   
  },
  onPaginationCompleted: () {
    // on pagination completion
  },
);
```
`onMonthLoaded` is a callback that fires for every month added to the list. When this function fires can be altered by setting the `invisibleMonthsThreshold` pararamter. 

`invisibleMonthsThreshold` decides how many months outside of the widgets view should be loaded. In other words, how many months should be preloaded before the user reaches that scroll position. It defaults to `1`.

`onDayPressed` is a simple `onPressed` callback but also provides the `DateTime` of the day that has been pressed.

finally when an `endDate` is provided to the `PagedVerticalCalendar`, the `onPaginationCompleted` callback can be used. This is a `VoidCallBack` that indicates when all the months have been loaded.




## :art: Customization

 `PagedVerticalCalendar` provides default calendar styling, but these can be fully customized. To do so, several builders are provided:

```dart
PagedVerticalCalendar(
  monthBuilder: (context, month, year) {
    // provide a month header widget
  },
  dayBuilder: (context, date) {
    // provide a day widget
  },
);
```

`monthBuilder` provides the year and month as `integers`. this builder has to return a widget that will form the header of ever month. the [intl](https://pub.dev/packages/intl) package works well here for date formatting.

`dayBuilder` provides the day as a `DateTime`. this builder wil be called for every day. You usually want to provide at least a text widget with the current day number. 

## :wave: Get Involved

If this package is useful to you please :thumbsup: on [pub.dev](https://pub.dev/packages) and :star: on github. If you have any Issues, recommendations or pull requests I'd love to see them!