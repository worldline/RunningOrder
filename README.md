# Running Order
A macOS SwiftUI app to help demonstrate developed User stories in a sprint.

![Image](Images/image1.png?)

## Goal
When you work in an Agile team, you need to show the changes of the finished sprint. This app is designed to help a development team organize which feature to show, in which order, with the right information such as links, usernames, environment names, ...

In order to collaborate with multiple members of the team and respect users’ privacy, all the information is stored in an iCloud private database owned by a member of the team.

## Roadmap
Currently this app is at a very early state of development. The first goal is to meet the requirements of one dev team at Worldline, be useful, and prove its value.

The second goal is to be generalized to other iOS development teams, as the app requires a Mac to work. Past this point, we'll see if we can launch the app on the Mac App Store, to reach development teams outside Worldline.

Then, develop a counterpart to reach other interested teams (iOS version, Windows version, or web, in order to work on desired platforms)

## Technical requirements
Currently the app supports macOS Catalina, but it will be upgraded to Big Sur soon to permit usage of newest SwiftUI changes.

You'll need an iCloud account on the Mac. (A cloudless functional build is not planned for now, but could be studied later)

You'll need Xcode 12 to build the app.

## Architecture
I wrote an article about the architecture of this project. For now it is under review for publishing in the [Worldline Engineering Blog](https://blog.worldline.tech).
You can also find a diagram that links all Managers, Views, Models, Services [here](Images/diagram.png?)
