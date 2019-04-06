<p align="center">
<img src="icon.png" />
</p>

<h1 align="center">Gatitos Delight (Kitty delight)</h1>
<p align="center">iOS cat sightseeing up for Felcana. Works with thecatapi.com </p>

## 📝 Design

Before starting coding, I needed to have some overall idea of how I wanted the application to look like. The requirements define that:

- The user should be able to see an image of a cat, as offered by the API.
- The user should be able to vote up or down a given image of a cat, as identified by the API.
- The user should be able to see the breed of the cat as an overlay in the image. The app should show some info about the breed as they click on it.
- The user should be able to filter by breed.

So with this in mind, I go to [Sketch](https://www.sketch.com) and starting making a mock-up of the application. I want it to be easy to use, so I want to use a visual language that is more or less ubiquitous. Since the website has a very simple yes/no interface, it makes sense to use a Tinder-like UX. Also it is a good time to define a basic logo. 

For the logo I used the iOS icon template of Sketch, to which I over imposed a kitty icon I found on Iconfinder. You can see the result at the begining of the document.

For the captions in the app I used the [Tiresias Infofont](https://www.fontsquirrel.com/fonts/tiresias-infofont) because is designed for visually impaired people - and I also think it looks nice 😄. With a palette generator I picked some colors and made an splash screen.

The design I came up with is a very simple navigation bar with three tabs: Cats, where you will rate cats, breeds, where you can choose a breed and sample cats; and an about screen. Also I lay down in Sketch hotspots so I can test the flow of the app as I design it. I find that that saves time in the long run.

When browsing the breeds, they will be alphabetically sorted with a mention of the country the breed comes from.

## 🛠 App. architecture

At this point I explored the API with a REST client, and noticed that sometimes the API doesn't return the breed type. The app needs to account for that. The Cat API gives you photos of cats, and also lets you see information of these breeds. Each has to be done separately.

The overall architecture will be MVC, using delegates to avoid coupling between View Controllers.

For package management I will use CocoaPods. For JSON support I will use SwiftlyJSON. For requests, Alamofire. For image downloading Kingfisher.

Once I had the basic application set, I set up a [Git Flow](https://danielkummer.github.io/git-flow-cheatsheet/) environment for development. This will allow me to separate development into features, so I can keep everything tidy.

