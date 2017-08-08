---
layout: post
title: Content Sharing
category: Training
tags: [Content Sharing]
---


[Building Apps with Content Sharing](https://developer.android.com/training/building-content-sharing.html)

## 1 Sharing Simple Data
### 1.1 Sending Simple Data to Other Apps
1. `ACTION_SEND`
2. specify the data and the type
3. add an `ActionBar` to use `ShareActionProvider`
4. [ShareActionProvider API](https://developer.android.com/training/sharing/shareaction.html)

#### 1.1.1 Send Text Content
1. `ACTION_SEND` action is sending text content
2. implement this type of sharing

	```
Intent sendIntent = new Intent();
sendIntent.setAction(Intent.ACTION_SEND);
sendIntent.putExtra(Intent.EXTRA_TEXT, "This is my text to send.");
sendIntent.setType("text/plain");
//startActivity(sendIntent);
startActivity(Intent.createChooser(sendIntent, getResources().getText(R.string.send_to)));
	```

3. MIME type `text/plain`, `Intent.EXTRA_TEXT`
4. 1+ app matches, the system displays a dialog to choose
5. call `Intent.createChooser()` to open specified app
6. standard extras `EXTRA_EMAIL, EXTRA_CC, EXTRA_BCC, EXTRA_SUBJECT`

#### 1.1.2 Send Binary Content
1. setAction `ACTION_SEND`
2. putExtra `Intent.EXTRA_STEARM`
3. MIME type, a wide variety of types: `*/*`, such as `image/jpeg`
4. `Uri`, `ConnectProvider, MediaStore`

```
Intent shareIntent = new Intent();
shareIntent.setAction(Intent.ACTION_SEND);
shareIntent.putExtra(Intent.EXTRA_STREAM, uriToImage);
shareIntent.setType("image/jpeg");
startActivity(Intent.createChooser(shareIntent, getResources().getText(R.string.send_to)));
```

#### 1.1.3 Send Multiple Pieces of Content
1. `ACTION_SEND_MULTIPLE` 
2. a list of `URIs`
3. a mixture of image types `image/*`

```
ArrayList<Uri> imageUris = new ArrayList<Uri>();
imageUris.add(imageUri1); // Add your image URIs here
imageUris.add(imageUri2);

Intent shareIntent = new Intent();
shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, imageUris);
shareIntent.setType("image/*");
startActivity(Intent.createChooser(shareIntent, "Share images to.."));
```

### 1.2 Receiving Simple Data from Other Apps
#### 1.2.1 Update Your Manifest
1. `<intent-filter>`

```
<activity android:name=".ui.MyActivity" >
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.SEND_MULTIPLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
</activity>
```

#### 1.2.2 Handle the Incoming Content
1. `getIntent()`
2. `intent.getAction()`
3. 	`intent.getType()`

```
// Get intent, action and MIME type
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    if (Intent.ACTION_SEND.equals(action) && type != null) {
        if ("text/plain".equals(type)) {
            // Handle text being sent
            	String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
        } else if (type.startsWith("image/")) {
           // Handle single image being sent
           Uri imageUri = (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
        }
    } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
        if (type.startsWith("image/")) {
            // Handle multiple images being sent
            ArrayList<Uri> imageUris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
        }
    } else {
        // Handle other intents, such as being started from the home screen
    }
```

3. process binary data in a separate thread


### 1.3 Adding an Easy Share Action
1. add an `ActionBar` to use `ShareActionProvider` with API 14+

#### 1.3.1 Update Menu Declarations
1. `android:actionProviderClass`
2. `<item>` in your menu resource file

```
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/menu_item_share"
        android:showAsAction="ifRoom"
        android:title="Share"
        android:actionProviderClass="android.widget.ShareActionProvider" />
</menu>
```

#### 1.3.2 Set the Share Intent
1. find `menuItem` when inflating menu resources in Activity or Fragment
2. call `MenuItem.getActionProvider()`
3. use `setShareIntent()` 

```
@Override
public boolean onCreateOptionsMenu(Menu menu) {
    // Inflate menu resource file.
    getMenuInflater().inflate(R.menu.share_menu, menu);
    // Locate MenuItem with ShareActionProvider
    MenuItem item = menu.findItem(R.id.menu_item_share);
    // Fetch and store ShareActionProvider
    mShareActionProvider = (ShareActionProvider) item.getActionProvider();
    // Return true to display menu
    return true;
}

```

## 2 Sharing Files
1. the file's content URI 
2. grant temporary access permissions to that URI
3. [FileProvider API](https://developer.android.com/reference/android/support/v4/content/FileProvider.html) `getUriForFile()`

### 2.1 Setting up File Sharing
#### 2.1.1 Specify the FileProvider
1. define a FileProvider in manifest, `<provider>`
2. specify the authoity in generating content URIs, `<android:authorities>` is your app package name with the string "fileprovider" appended to it

```
<provider
    android:name="android.support.v4.content.FileProvider"
    android:authorities="com.example.myapp.fileprovider"
    android:grantUriPermissions="true"
    android:exported="false">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/filepaths" />
</provider>
```
#### 2.1.2 Specify Sharable Directories
1. create `res/xml/filepath.xml` 
2. share directories within the files/directory of your app's internal storage,such as `files/images/myimages`
3. `<external-path>, <cache-path>`

```
<paths>
    <files-path path="images/" name="myimages" />
</paths>
```

### 2.2 Sharing a File
1. create a file selection Activity to respond the requests for files

#### 2.2.1 Receive File Requests
1. `startActivityForResult()` with `Intent.ACTION_PICK`

#### 2.2.2 Create a File Selection Activity
1. set an intent filter matches the action `ACTION_PICK` and the categories `CATEGORY_DEFAULT, CATEGORY_OPENABLE`
2. add MINME type for the filter

```
<activity
    android:name=".FileSelectActivity"
    android:label="@File Selector" >
    <intent-filter>
        <action
            android:name="android.intent.action.PICK"/>
        <category
            android:name="android.intent.category.DEFAULT"/>
        <category
           android:name="android.intent.category.OPENABLE"/>
        <data android:mimeType="text/plain"/>
        <data android:mimeType="image/*"/>
    </intent-filter>
</activity>

```

#### 2.2.3 Define the file selection Activity in code

```
// Set up an Intent to send back to apps that request a file
mResultIntent = new Intent("com.example.myapp.ACTION_RETURN_FILE");
// Get the files/subdirectory of internal storage
mPrivateRootDir = getFilesDir();
mImagesDir = new File(mPrivateRootDir, "images");
mImageFiles = mImagesDir.listFiles();
setResult(Activity.RESULT_CANCELED, null);
```

#### 2.2.4 Respond to a File Selection


### 2.3 Requesting a Shared File
#### 2.3.1 Send a Request for the File

```
mRequestFileIntent = new Intent(Intent.ACTION_PICK);
mRequestFileIntent.setType("image/jpg");
/**
 * When the user requests a file, send an Intent to the
 * server app.
 */
startActivityForResult(mRequestFileIntent, 0);
```

#### 2.3.2 Acess the Requested File
1. the server app sends the file's content URI back to the client app
2. `onActivityResult()`
3. access the file by getting its `FileDescriptor`

```
@Override
public void onActivityResult(int requestCode, int resultCode, Intent returnIntent) {
	// If the selection didn't work
	if (resultCode != RESULT_OK)
	   return;
	   
	// Get the file's content URI from the incoming Intent
	Uri returnUri = returnIntent.getData();
	// Try to open the file for "read" access using the returned URI. If the file isn't found, write to the
	// error log and return.
	try {
	    // Get the content resolver instance for this context, and use it
	    // to get a ParcelFileDescriptor for the file.
	    mInputPFD = getContentResolver().openFileDescriptor(returnUri, "r");
	} catch (FileNotFoundException e) {
	    e.printStackTrace();
	    Log.e("MainActivity", "File not found.");
	    return;
	}
	// Get a regular file descriptor for the file
	FileDescriptor fd = mInputPFD.getFileDescriptor();
}
```

### 2.4 Retrieving File Information
#### 2.4.1 Retrieve a File's MIME Type
1. the client calls `ContentResolver.getType()`, return the file's MIME type

```
//Get the file's content URI from the incoming Intent, thenget the file's MIME type
Uri returnUri = returnIntent.getData();
String mimeType = getContentResolver().getType(returnType);
```

#### 2.4.2 Retrieve a File's Name and Size
1. `ContentResolver().query()`
2. `Cursor` returns DISPLAY_NAME(`File.getName()`), SIZE(`File.length()`)

```
//query the server app to get the file's display name and size
Uri returnUri = returnIntent.getData();
Cursor returnCursor = getContentResolver().query(returnUri, null, null, null, null);
int nameIndex = returnCursor.getColumnIndex(OpenableColumn.DISPLAY_NAME);
int sizeIndex = returnCursor.getColumnIndex(OpenableColumn.SIZE);
returnCursor.moveToFirst();
String displayName = returnCursor.getString(nameIndex);
long size = returnCursor.getLong(sizeIndex);
```

## 3 Sharing Files with NFC

### 3.1 Sending Files to Another Device
1. resquest permission to use NFC
2. test to ensure your device supports NFC and External Storage
3. provide URIs to Android Beam file transfer, API Level 16+(Android 4.1)
4. `File.setReadable(true, false)`

#### 3.1.1 Declare Features in the Manifest
1. Request Permissions

	```
 <uses-permission android:name="android.permission.NFC" />
 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
	```

2. Specify Android Beam file transfer
	
	NFC isn't present, set `android:required="false"`, and test it 

	```
<uses-feature
    android:name="android.hardware.nfc"
    android:required="true" />
	```

3. Specify Android Beam file transfer

	```
	<uses-sdk android:minSdkVersion="16+"/>
	```

#### 3.1.2 Test for Android Beam File Transfer Support
1. test `PackageManager.hasSystemFeature()`,`FEATURE_NFC`
2. test the value of `SDK_INT`

```
// NFC isn't available on the device
if (!PackageManager.hasSystemFeature(PackageManager.FEATURE_NFC)) {
    //Disable NFC features here.
    //For example, disable menu items or buttons that activate NFC-related features
    
// Android Beam file transfer isn't supported
} else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR1) {
    // If Android Beam isn't available, don't continue.
    mAndroidBeamAvailable = false;
    // Disable Android Beam file transfer features here.
    
// Android Beam file transfer is available, continue
} else {
	mNfcAdapter = NfcAdapter.getDefaultAdapter(this);
}
```

#### 3.1.3 Create a Callback Method that Provides Files
1. implement `NfcAdapter.CreateBeamUrisCallback()`
2. override `createBeamUris`, return an array of Uri objects

	```
//Callback that Android Beam file transfer calls to get files to share
private class FileUriCallback implements NfcAdapter.CreateBeamUrisCallback {//at Activity
    public FileUriCallback() { }
    //Create content URIs as needed to share with another device
    @Override
    public Uri[] createBeamUris(NfcEvent event) {
        return mFileUris;
    }
}
	```

3. call `setBeamPushUrisCallback()`, [NfcAdapter API](https://developer.android.com/reference/android/nfc/NfcAdapter.html)

```
// Android Beam file transfer is available, continue
...
mNfcAdapter = NfcAdapter.getDefaultAdapter(this);
//Instantiate a new FileUriCallback to handle requests for URIs
mFileUriCallback = new FileUriCallback();
// Set the dynamic callback for URI requests.
mNfcAdapter.setBeamPushUrisCallback(mFileUriCallback, this);
```

#### 3.1.4 Specify the Files to Send
1. get a file URI for each file

```
//Create a list of URIs, get a File, and set its permissions
private Uri[] mFileUris = new Uri[10];
String transferFile = "transferimage.jpg";
File extDir = getExternalFilesDir(null);
File requestFile = new File(extDir, transferFile);
requestFile.setReadable(true, false);
// Get a URI for the File and add it to the list of URIs
fileUri = Uri.fromFile(requestFile);
if (fileUri != null) {
    mFileUris[0] = fileUri;
} else {
    Log.e("My Activity", "No File URI available for file.");
}
```

### 3.2 Receiving Files from Another Device

#### 3.2.1 Respond to a Request to Display Data
1. copy files to the receiving device 
2. post a notification containing an Intent

```
<activity
    android:name="com.example.android.nfctransfer.ViewActivity"
    android:label="Android Beam Viewer" >
    ...
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <data android:mimeType=""/>
    </intent-filter>
</activity>
```

#### 3.2.2 Request File Permissions
1. copy to the device, you can request WRITE instand

``` <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### 3.2.3 Get the Directory for Copied Files 
1. examine the incoming Intent's scheme and authority
2. `Uri.getScheme()`

```
String action = mIntent.getAction();
// For ACTION_VIEW, the Activity is being asked to display data.
if (TextUtils.equals(action, Intent.ACTION_VIEW)) {
    // Get the URI from the Intent
    Uri beamUri = mIntent.getData();
    // Test for the type of URI, by getting its scheme value
    if (TextUtils.equals(beamUri.getScheme(), "file")) {
        mParentPath = handleFileUri(beamUri);
    } else if (TextUtils.equals(beamUri.getScheme(), "content")) {
        mParentPath = handleContentUri(beamUri);
    }
}
```

#### 3.3.3 Get the directory from a file URI
1. get absolute file name, path from incoming Intent containing a file URI

```
public String handleFileUri(Uri beamUri) {
    // Get the path part of the URI
    String fileName = beamUri.getPath();
    // Create a File object for this filename
    File copiedFile = new File(fileName);
    // Get a string containing the file's parent directory
    return copiedFile.getParent();
}
```

#### 3.3.4 Get the directory from a content URI
1. retrieve a directory and file name for the content URI contained incoming Intent
2. get MIME type of `audio/*, image/*, video/*` from media-related file
3. Determine the content provider, `Uri.getAuthority()`

```
public String handleContentUri(Uri beamUri) {
    // Position of the filename in the query Cursor
    int filenameIndex;
    File copiedFile;
    // The filename stored in MediaStore
    String fileName;
    // Test the authority of the URI
    if (!TextUtils.equals(beamUri.getAuthority(), MediaStore.AUTHORITY)){
        //Handle content URIs for other content providers
    } else {
        // Get the column that contains the file name
        String[] projection = { MediaStore.MediaColumns.DATA };
        Cursor pathCursor = getContentResolver().query(beamUri, projection, null, null, null);
        // Check for a valid cursor
        if (pathCursor != null && pathCursor.moveToFirst()) {
            filenameIndex = pathCursor.getColumnIndex(MediaStore.MediaColumns.DATA);
            // Get the full file name including path
            fileName = pathCursor.getString(filenameIndex);
            copiedFile = new File(fileName);
            return new File(copiedFile.getParent());
         } else {
            // The query didn't work
            return null;
         }
    }
}
```

























