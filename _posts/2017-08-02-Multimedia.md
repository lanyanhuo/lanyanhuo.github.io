---
layout: post
title: Multimedia
category: Training
tags: [Multimedia]
---

[Building Apps with Multimedia](https://developer.android.com/training/camera/index.html)


## 1 Capturing Photo

### 1.1 Taking Photos Simply
#### 1.1.1 Request Camera Permission

```
uses-feature android:name="android.hardware.camera" android:required="true" />
```

1. at runtime, call `hasSystemFeature(PackageManager.FEATURE_CAMERA)` to check for the availablity of the camera

#### 1.1.2 Take a Photo with the Camera App
1. new Intent
2. startActivity
3. handle the image data

```
static final int REQUEST_IMAGE_CAPTURE = 1;

private void dispatchTakePictureIntent() {
    Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
        startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
    }
}
```

#### 1.1.3 Get the Thumbnail
1. taking photos isn't the culmination of your app's ambition
2. back to app from the camera
3. encode the key `data` as a small `Bitmap` in the extras of the return Intent delivered to `onActivityResult()`

```
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
    if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
        Bundle extras = intent.getExtras();
        Bitmap imageBitmap = (Bitmap) extras.get("data");
        mImageView.setImageBitmap(imageBitmap);
    }
}
```

#### 1.1.4 Save the Full-size Photo
1. save to the public external storage, so request permission `WRITE_EXTERNAL_STORAGE`
2. `getExternalStoragePublicDirectory()` with `DIRECTORY_PICTURES` argument
3. but remain private to your app only. use `getExternalFilesDir()`, request permission `WRITE_EXTERNAL_STORAGE` and `maxSdkVersion="18"`
4. uninstall your app, and delete the directories provided by `getExternalFilesDir(), getFilesDir()`

```
static final int REQUEST_TAKE_PHOTO = 1;
String mCurrentPhotoPath;

private void dispatchTakePictureIntent() {
    Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    // Ensure that there's a camera activity to handle the intent
    if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
        // Create the File where the photo should go
        File photoFile = null;
        try {
            photoFile = createImageFile();
        } catch (IOException ex) {
            // Error occurred while creating the File
        }
        // Continue only if the File was successfully created
        if (photoFile != null) {
            Uri photoURI = FileProvider.getUriForFile(this, "com.example.android.fileprovider",photoFile);
            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
            startActivityForResult(takePictureIntent, REQUEST_TAKE_PHOTO);
        }
    }
}

private File createImageFile() throws IOException {
    // Create an image file name
    String timeStamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Data());
    String imageFileName = "JPEG_" + timeStamp + "_";
    File storagetDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    File image = File.createTempFile(
    		imageFileName,	// prefix
    		".jpg",			// suffix
    		storageDir		// directory
    };
    
    // Save a file: path for use with ACTION_VIEW intents
    mCurrentPhotoPath = image.getAbsolutePath();
    return image;
}

```

```
//AndroidManifest.xml
<provider 
	android:name="android.support.v4.content.FileProvider"
	android:authorities="com.example.android.fileprovider"
	android:exported="false"
	android:grantUriPermission="true">
	<meta-data
		android:name="android.support.FILE_PROVIDER_PATHS"
		android:resource="@xml/file_paths">
	</meta-data>
</provider>
```

```
//res/xml/file_paths.xml
<path xmlns:android="http://schemas.android.com/apk/res/android">
	<external-path name="my_images" path="Android/data/com.example.package.name/files/Pictures"/>
</path>
```

#### 1.1.5 Add the Photo to a Gallery

```
private void galleryAddPic() {
	Intent mediaScanIntent = new Intent(Intent.ACION_MEDIA_SCANNER_SCAN_FILE);
	File f = new File(mCurrentPhotoPath);
	Uri contentUri = Uri.fromFile(f);
	mediaScanIntent.setData(contentUri);
	this.sendBroadcast(mediaScanIntent);
}
``` 

#### 1.1.6 Decode a Scaled Image
1. full-sized images can be tricky with limited memory
2. reduce the amount of dynamic heap
3. a memory array scaled to match the size of the destination view

```
private void setPic() {
	//Get the dimensions of the view
	int targetW = mImageView.getWidth();
	int targetH = mImageView.getHeigth();
	
	//Get the dimensions of the bitmap
	BitmapFactory.Options bmOptions = new BitmapFactory.Options();
	bmOptions.inJustDecodeBounds = true;
	BitmapFactory.decoderFile(mCurrentPhotoPath, bmOptions);
	int photoW = bmOptions.outWidth;
	int photoH = bmOptions.outHeight;
	
	//Determine how much to scale down the image
	int scaleFactor = Math.min(photoW/targetW, photoH/targetH);
	
	//Decode the image file into a Bitmap sized to fill the view
	bmOptions.inJustDecodeBounds = false;
	bmOptions.inSampleSize = scaleFactor;
	bmOptions.inPurgable = true;
	
	Bitmap bitmap = BitmapFactory.decodeFile(mCurrentPhotoPath, bmOptions);
	mImageView.setImageBitmap(bitmap);
```


### 1.2 Recording Videos Simply
#### 1.2.1 Request Camera Permission (as Taking Photos permission)
#### 1.2.2 Record a Video with a Camera App
1. `MediaStore.ACTION_VIDEO_CAPTURE`
2. as Taking Photos `startActivityForResult()`

#### 1.2.3 View the video
1. as Taking photos `onActivityResult() `

```
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
	if (requestCode == REQUEST_VIDEO_CAPTURE && resultCode == RESULT_OK) {
		Uri videoUri = intent.getData();
		mVideoView.setVideoURI(videoUri);
	}
}
```


### 1.3 Controlling the Camera
#### 1.3.1 Open the Camera Object
1. get an instance of Camera Object, `Camera.open(id)`
2. open Camera on separate thread from `onCreate()`
3. `onResume()` to facilitate code reuse and keep the flow of control simple

#### 1.3.2 Create the Camera Preview
1. click the shutter

#### 1.3.3 Modify Camera Settings

#### 1.3.4 Set the Preview Orientation

#### 1.3.5 Take a Picture

#### 1.3.6 Restart the Preview

#### 1.3.7 Stop the Preview and Release the Camera

## 2 Printing Content
1. users frequently view content solely
2. share information
3. create a snapshot of information

### 2.1 Printing a Photo
1. take and share photos 
2. use `PrintHelper`

#### 2.1.1 Print an Image
1. `setScaleMode()`, two options : `SCALE_MODE_FIT, SCALE_MODE_FILL(default)`

```
private void doPhotoPrint() {
	PrintHelper photoPrinter = new PrintHelper(getActivity());
	photoPrinter.setScaleMode(PrintHelper.SCALE_MODE_FIT);
	Bitmap bitmap = BitmapFactory.decodeResource(getResource(), R.drawable.droid)l
	photoPrinter.printBitmap("droids.jpg - test print", bitmap);
```

### 2.2 Printing an HTTML Document
#### 2.2.1 Load an HTML Document
1. load the HTML resource into the Webview object
2. `WebViewClient` starts a print job

#### 2.2.2 Create a Print job

### 2.3 Printing a Custom Document
1. how to connect to the Android print manager, create a print adapter and build content for printing














































