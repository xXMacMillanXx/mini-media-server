# MediaServer

💧 A project built with the Vapor web framework.

A reimagination of my FastHTML project [Local Media Center](https://github.com/xXMacMillanXx/local-media-provider), since I wanted to play more around with Swift.

It supports the same features:

Currently the project is looking for a media folder in the Public directory. You can copy some files there to test, or create a symlink to a folder called media.

```bash
ln -s /path/to/media/you/want/to/see media
```

If you want to add online media (e.g., youtube videos) you can create a .link file which contains the link to the video. Copy the embed link from the video. (YouTube: Share -> Embed -> copy link from src attribute)

For example, a link file for the Youtube rewind 2014, would look like this:
Filename: *Youtube Rewind 2024.link*

```text
https://www.youtube.com/embed/zKx2B8WCQuw
```

## Getting Started


### Dependencies

The project uses [HTMX](https://github.com/bigskysoftware/htmx) 2.0.7 and [Bulma](https://github.com/jgthms/bulma) 1.0.4.

See `Resources/Views/index.leaf` for the links and path. I renamed the htmx.min.js and bulma.min.css to include their version number.

### Run the project

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```
I didn't write tests, so... yeah.

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)
