# CustomerGlu

CustomerGlu SDK provides you lots of in-built stuff and make your integration faster with CustomerGlu
Our SDK provides you In-built functions you just need to use them.

# Prerequisite

iOS - Requires IOS 11.0 or above.

Xcode - Version 13.0 or above

# Installation

1. Open Xcode.
2. Click on Your app Name Open General.
3. Click on + Button under Framework,Library and Embedded Content.
4. Click on Add Other.
5. Select Add Package dependency.
6. Paste the repo url here - https://github.com/customerglu/CG-iOS-SDK  
7. Click on Add packages.

# Initialise CustomerGlu SDK 

Mandatory step and need to put CustomerGlu WRITE_KEY in Info.plist
``` 
<key>CUSTOMERGLU_WRITE_KEY</key>
<string>YOUR_WRITE_KEY</string>

```
Define the global instance of CustomerGlu SDK -  CustomerGlu SDK follows singleton pattern so you need to initialise it once
``` 
let customerglu = CustomerGlu.getInstance

```

# Functionalities

[Supported Functionality Document](https://docs.customerglu.com/sdk/ios)
