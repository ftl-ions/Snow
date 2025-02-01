# Snow

❄️ A fork of Ice, the developer friendly package manager for Swift; 100% compatible with Swift Package Manager

## About

Snow is a fork of Ice that maintains all of Ice's developer-friendly features while adding enhanced watching and preprocessing capabilities.

#### More Paths

In addition to Sources, Snow can watch additional directories for changes during `build -w` and `run -w` operations.

#### External Tools

Snow can run preprocessing tools before each build.

### Installation

```bash
git clone https://github.com/ftl-ions/Snow
cd Snow
swift build -c release
install .build/release/snow /usr/local/bin
```

## Usage

### Configuration

Here is an example for `snow.json`, which adds a [Tailwind CSS](https://tailwindcss.com) preprocessor and watches for changes in the `Resources` directory, too.

Place this file in the root of your project (where `Package.swift` is).

```
{
    "externalTools" : [
        {
            "exec" : "npx",
            "args" : [
                "@tailwindcss/cli",
                "-i",
                "./Resources/input.css",
                "-o",
                "./Public/css/site.css"
            ]
        }
    ],
    "watchPaths" : [
        {
            "path" : "Resources",
            "extensions" : [
                "leaf", "css"
            ]
        }
    ]
}
```

Multiple tools and watch paths can be configured.

### Everything Else

Otherwise, Snow works [exactly like Ice](https://github.com/jakeheis/Ice?tab=readme-ov-file#imperatively-manage-packageswift).
