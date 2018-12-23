<h1 align="center">
    Sx
</h1>

<p align="center">
    Declarative components in Swift
    <br/>
    <br/>
    <a href="https://github.com/Sx-bot/builds/tree/master/master/iOS">
        <img alt="Build status iOS" src="https://builds.swift.sx/master/badge-iOS.svg"/>
    </a>
    <a href="https://github.com/Sx-bot/builds/tree/master/master/macOS">
        <img alt="Build status macOS" src="https://builds.swift.sx/master/badge-macOS.svg"/>
    </a>
    <a href="https://github.com/Sx-bot/builds/tree/master/master/watchOS">
        <img alt="Build status watchOS" src="https://builds.swift.sx/master/badge-watchOS.svg"/>
    </a>
    <a href="https://github.com/Sx-bot/builds/tree/master/master/tvOS">
        <img alt="Build status tvOS" src="https://builds.swift.sx/master/badge-tvOS.svg"/>
    </a>
    <a href="https://github.com/Sx-bot/builds/tree/master/master">
        <img alt="Code coverage" src="https://builds.swift.sx/master/badge-coverage.svg"/>
    </a>
</p>

#### How Does It Work

```swift
let valid = fields.allSatisfy({ $0.valid })

return [
    View(backgroundColor: .blue, fields.map({[
        Label(label: $0.label),
        TextInput(label: $0.value, onEvent: handleEvent($0.value))
    ]}),
    Button(label: 'Submit', disabled: dirty && !valid)
]
```

```swift
/*
 * let entries = [
 *   Field(label: "Name", value: "John", valid: true),
 *   Field(label: "Surname", value: "John", valid: true),
 *   Field(label: "Birthday", value: nil, valid: false)
 * ]
 *
 * let dirty = true
 */
```

Bla tree diff

#### Use Case: User Interfaces

For building UIs, using declarative APIs has already proven great success on the web platform with libraries like [React](https://github.com/facebook/react/). In the paradigm of functional programming, UI code mostly consists of functions that map between state and UI elements. That approach allows you to think of your application as a (pure) representation of state and side effects are kept to a minimum.

In summary:

- clean and easy-to-follow logic: functions return UI elements, that depend on their arguments only
- components are unit testable: UI logic can be verified without launching the full application
- bugs can be reproduced more reliably: the application can be rerendered in a state that was present before the bug occured and actions can be replayed that lead to the invalid state

#### Prior Art

There have been various approaches to bring the same concept to native platforms. Some of them were bridging [existing JavaScript libraries](https://github.com/facebook/react-native), while others .

#### Name

The name Sx has been loosely inspired by [**s**ymbolic e**x**pressions](https://en.wikipedia.org/wiki/S-expression) and the fact that this library compliments well with [Rx](https://github.com/ReactiveX/RxSwift), so a related name was chosen to highlight the synergy.

#### Acknowledgements

Sx was heavily inspired by React and I want to thank their team especially for the outstanding [implementation notes](https://reactjs.org/docs/implementation-notes.html), which I used heavily for reference.
