# README #

# Features #

<img src="https://user-images.githubusercontent.com/32564846/34433123-4873eca4-ec7d-11e7-8a80-4ad54def8653.png" width="250">  <img src="https://user-images.githubusercontent.com/32564846/34433130-5a797022-ec7d-11e7-94c0-cd91cb7a7e3b.png" width="250"> <img src="https://user-images.githubusercontent.com/32564846/34433695-39e04468-ec81-11e7-84a3-920e9098a2a1.png" width="250">


Chat21 is a *multiplatform chat SDK* developed using only Firebase as the backend.

This demo shows the following features:

* Tab based chat application
* Recent conversations' list
* Direct message (one to one message)
* Offline messages' history
* Received receipts (you can see if a message was sent and delivered)
* Presence Manager with online/offline and inactivity period indicator
* Integration of a custom user profile's view
* Signup/Login with email and password
* Synchronized contacts (with offline search and selection)
* Integrates an example of a mobile live-chat support (an "help" button on the top left corner of every tab)

# Install & run #

Before you do anything else, you shoud change the Bundle Identifier, and assign an appropriate Team.

Select **chat21** in the **Project Navigator**, and then select the **chat21** target. In the **General tab** change **Bundle Identifier** to use your own domain name, in reverse-domain-notation - for example **it.mycompany.mychat**.
Then, from the **Team** menu, select the team associated with your developer account like so:

<img width="1103" alt="xcode-conf" src="https://user-images.githubusercontent.com/32564846/36319768-44454388-1344-11e8-9033-c2290fa018fa.png">


1. Create a new project on [firebase](https://firebase.google.com) site
2. Select the option **Add Firebase to your iOS app**
3. Configure you Xcode project copying your Google-Info.plist (download the file from the Firebase iOS App dashboard).
5. Run "pod install" in the Xcode project folder.
6. Download & install libs: Chat21Core & Chat21UI folders from [here](https://github.com/chat21/chat21-cloud-functions). Drag & drop the two folders in the Xcode project
7. Install the Firebase cloud functions available [here](https://github.com/chat21/chat21-cloud-functions). Follow the included instructions. This will setup your backend.

Now you can build & launch the project using the file "chat21.xcworkspace".

More detailed instructions will be available soon.

Meanwhile feel free to ask for support at support@frontiere21.it.

Enjoy!
