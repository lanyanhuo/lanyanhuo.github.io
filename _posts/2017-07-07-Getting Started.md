---
layout: post
title: Getting Started
category: Training
tags: [Getting Started]
---

[Develop/Training/Getting Started](https://developer.android.com/training/index.html)
## 1	Building Your First App### 1.1 Create an Android project### 1.2 Run Your App### 1.3 Build a simple User Interface[https://developer.android.com/training/basics/firstapp/building-ui.html](https://developer.android.com/training/basics/firstapp/building-ui.html)

### 1.4 Start Another Activity2	Building Your First App### 2.1 Different Languages and Cultures1.	culture-specific strings —— the languages of current locale2.	top level `res/value/string.xml`
#### 2.1.1	Create Locale Directories and Resources files 1.	values-b+es/string.xml, mipmap-b+es+ES/2.	android loads res according the locale Settings
3. [Guides/App Resources](https://developer.android.com/guide/topics/resources/index.html)#### 2.1.2	Use the resources in your app1.	Code `getResources().getString(R.string.hello_world)`2.	Xml files `android:src="@mipmap/country_flag"`### 2.2 Different Screens1.	Device screens category : size, density 大小和密度small, normal, large, xlarge，low (ldpi), medium (mdpi), high (hdpi), extra high (xhdpi)2.	In separate directories 不同目录3.	The screens orientation: landscape or portrait屏幕方向#### 2.2.1 Create Different Layouts1. res/layout-large/ layout-land/ layout（portrait）layout-large-land/2. `setContentView(R.layout.main)`3. [Training/Best Practices for user interface](https://developer.android.com/training/multiscreen/index.html)#### 2.2.2 Create Different Bitmaps1. xhdpi: 2.0 hdpi: 1.5 mdpi: 1.0 (baseline) ldpi: 0.752. [Material Design](https://material.io/guidelines/style/icons.html#icons-product-icons)### 2.3 Different Platform Versions1. dashboards  
2. Android/Dashboards ——https://developer.android.com/about/dashboards/index.html#### 2.3.1 Specify minimum and Target API Levels

```<uses-sdk android:minSdkVersion="4"android:targetSdkVersion="15" />
```#### 2.3.2 Check System Version at RunTime1. Build.java 2. check	
	```	if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {      		ActionBar actionBar = getActionBar();      		actionBar.setDisplayHomeAsUpEnabled(true);	}
	```
3.	`android:showAsAction="ifRoom"`#### 2.3.2 Use Platform Styles and Themes1. To make your activity look like a dialog box:`<activity android:theme="@android:style/Theme.Dialog">`2. To make your activity have a transparent background:`<activity android:theme="@android:style/Theme.Translucent">`3. To apply your own custom theme defined in /res/values/styles.xml `<activity android:theme="@style/CustomTheme">`4. To apply a theme to your entire app (all activities), add the android:theme attribute to the <application> element:`<application android:theme="@style/CustomTheme">`5. [API Guides/User Interface/Styles and Themes](https://developer.android.com/guide/topics/ui/themes.html)## 3	Building a Dynamic UI (with Fragments)
1.	fragment as a modular section of an activity2.	support Library: v4, v7 appcompat3.	[Fragment API](https://developer.android.com/training/basics/fragments/index.html)### 3.1 Create a Fragment Class1. onCreateView, `inflate(R.layout.fragment)`2. [API Guides/App Components/Fragments](https://developer.android.com/guide/components/fragments.html)#### 3.1.2 Add a Fragment to an Activity using XML`<fragment android:name="com.example.android.fragments.HeadlinesFragment"`### 3.2 Building a Flexible UI ——FragmentManager #### 3.2.1 Add a Fragment to an Activity at Runtime1.	activity layout must include fragment view: FrameLayout2.	call getSupportFragmentManager() to get a FragmentManager
```if (findViewById(R.id.fragment_container) != null) {if (savedInstanceState != null) {   return;}// Create a new Fragment to be placed in the activity layoutHeadlinesFragment firstFragment = new HeadlinesFragment();firstFragment.setArguments(getIntent().getExtras());getSupportFragmentManager().beginTransaction().add(R.id.fragment_container, firstFragment).commit();}
```#### 3.2.2 Replace one Fragment with Another11.	replace() instand of add()2.	call addToBackStack()before commit() ——navigate backward3.	FragmentTransaction```// Create fragment and give it an argument specifying the article it should showArticleFragment newFragment = new ArticleFragment();Bundle args = new Bundle();args.putInt(ArticleFragment.ARG_POSITION, position);newFragment.setArguments(args);FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();// Replace whatever is in the fragment_container view with this fragment, and add the transaction to the back stack so the user can navigate backtransaction.replace(R.id.fragment_container, newFragment);transaction.addToBackStack(null);// Commit the transactiontransaction.commit();```
### 3.3 Communicating with other Fragments1.	assoicate them with an activity2.	Two Fragments should never communicate directly.#### 3.3.1 Define an Interface#### 3.3.2 Implement the Interface#### 3.3.3 Deliver a Message to a Fragment
## 4 Saving Data1. manage large amounts of information in files and databases.

### 4.1 Saving Key-Value Sets 
1. use a shared perferences file
2. small collection of key-values
3. [SharedPerference API](https://developer.android.com/reference/android/content/SharedPreferences.html)
4. read and write key-values pairs
5. do not confuse SharedPerferences with [Perference(build UI for your app Setting)](https://developer.android.com/reference/android/preference/Preference.html)

#### 4.1.1 Get a Handle to a SharedPerferences
1. `getContext().getSharedPerferences()`
2. 	`getActivity().getPerferences()`

#### 4.1.2 Write to SharedPerferences
1. create a SharedPerference.Editor by calling `edit()`
2. write with methods such as `putInt(), putString()`
3. `commit() ` to save the changes

```
SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
SharedPreferences.Editor editor = sharedPref.edit();
editor.putInt(getString(R.string.saved_high_score), newHighScore);
editor.commit();
```

#### 4.1.3 Read from SharedPerferences
1. `getInt(), getString()`

```
SharedPreferences sharedPref = getActivity().getPreferences(Context.MODE_PRIVATE);
int defaultValue = getResources().getInteger(R.string.saved_high_score_default);
long highScore = sharedPref.getInt(getString(R.string.saved_high_score), defaultValue);
```

### 4.2 Saving files
1. [File API](https://developer.android.com/reference/java/io/File.html)
2. a large amounts of data, such as anything exchanged over a network

#### 4.2.1 Choose Internal or External Storage
1. Internal Storage
	* always available
	* be accessible by only your app
	* uninstall app meanwhile remove all your app's files
2. External Storage (sdcard)
	* not always available
	* worlf-readable, anybody may read
	* uninstall app, remove your app's files only if from `getExternalFileDir()` to save 
3. install onto the internal storage by default, but specify `android:installLocation` attribute to install app on external storage. See [App Install Location](https://developer.android.com/guide/topics/data/install-location.html)

#### 4.2.2 Obtain Permissions for External Storage

1. if your app uses `WRITE_EXTERNAL_STORAGE`, it has reading permission as well

```
<manifest ...>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ...
</manifest>
```

#### 4.2.3 Save a File on Internal Storage
1. `getFilesDir()`

#### 4.2.4 Save a File in External Storage 

#### 4.2.5 Query Free Space

#### 4.2.6 Delete a File


### 4.3 Saving Data in SQL Databases
1. [sqlite API](https://developer.android.com/reference/android/database/sqlite/package-summary.html)

#### 4.3.1 Define a Schema(架构) and Contract(契约)
1. a formal declaration of how the db is organized
2. companion class(Contract class), in a systematic and self-documenting way
3. Contract class is a containter for constants uris, tables, columns
4. implement `BaseColumns`

```
public final class FeedReaderContract {
    // To prevent someone from accidentally instantiating the contract class,
    // make the constructor private.
    private FeedReaderContract() {}

    /* Inner class that defines the table contents */
    public static class FeedEntry implements BaseColumns {
        public static final String TABLE_NAME = "entry";
        public static final String COLUMN_NAME_TITLE = "title";
        public static final String COLUMN_NAME_SUBTITLE = "subtitle";
    }
}
```

#### 4.3.1 Create a DataBase Using a SQL Helper
1. create and deleta a table in db

```
private static final String SQL_CREATE_ENTRIES =
    "CREATE TABLE " + FeedEntry.TABLE_NAME + " (" +
    FeedEntry._ID + " INTEGER PRIMARY KEY," +
    FeedEntry.COLUMN_NAME_TITLE + " TEXT," +
    FeedEntry.COLUMN_NAME_SUBTITLE + " TEXT)";

private static final String SQL_DELETE_ENTRIES =
    "DROP TABLE IF EXISTS " + FeedEntry.TABLE_NAME;

```

2. `getWritable/ReadableDataBase()` update db  
3. `extends SQLiteOpenHelper ` override `onCreate(), onUpgrade(), onOpen()`

#### 4.3.2 Put Information into a Database

```
// Gets the data repository in write mode
SQLiteDatabase db = mDbHelper.getWritableDatabase();

// Create a new map of values, where column names are the keys
ContentValues values = new ContentValues();
values.put(FeedEntry.COLUMN_NAME_TITLE, title);
values.put(FeedEntry.COLUMN_NAME_SUBTITLE, subtitle);

// Insert the new row, returning the primary key value of the new row
long newRowId = db.insert(FeedEntry.TABLE_NAME, null, values);
```

#### 4.3.3 Read Information form a Database

```
SQLiteDatabase db = mDbHelper.getReadableDatabase();
// Define a projection that specifies which columns from the database
// you will actually use after this query.
String[] projection = {
    FeedEntry._ID,
    FeedEntry.COLUMN_NAME_TITLE,
    FeedEntry.COLUMN_NAME_SUBTITLE
    };

// Filter results WHERE "title" = 'My Title'
String selection = FeedEntry.COLUMN_NAME_TITLE + " = ?";
String[] selectionArgs = { "My Title" };

// How you want the results sorted in the resulting Cursor
String sortOrder =
    FeedEntry.COLUMN_NAME_SUBTITLE + " DESC";

Cursor c = db.query(
    FeedEntry.TABLE_NAME,                     // The table to query
    projection,                               // The columns to return
    selection,                                // The columns for the WHERE clause
    selectionArgs,                            // The values for the WHERE clause
    null,                                     // don't group the rows
    null,                                     // don't filter by row groups
    sortOrder                                 // The sort order
    );
```

#### 4.3.4 Delete Information from a Database

```
String selection = FeedEntry.COLUMN_NAME_TITLE + "LIKE ?";
String[] selectionArgs = {"MyTitle"};
db.delete(FeedEntry.TABLE_NAME, selection, selectionArgs);
```

#### 4.3.5 Update a Database

```
SQLiteDatabase db = dbHelper.getWritableDatabase();
//new value for one column
ContentValues values = new ContentValues();
values.put(FeedEntry.COLUMN_NAME_TITLE, title);

//which row to update, based on the title
String selection = FeedEntry.COLUMN_NAME_TITLE + "LIKE ?";
String[] selectionArgs = {"MyTitle"};
int count = db.update(
	FeedReaderDbHelper.FeddEntry.TABLE_NAME, values, selection, selectionArgs);
```


## 5 Interacting with Other apps startActivity by Intent### 5.1 Sending the user to Another Appan implicit Intent,  particular action
#### 5.1.1 Build an Implicit Intent1. uri

	```	Uri number = Uri.parse("tel:5551234");	Intent callIntent = new Intent(Intent.ACTION_DIAL, number);
	```
2. putExtra(), setType()——MIME type#### 5.1.2 Verfy There is an App to Receive the Intent

```PackageManager packageManager = getPackageManager();List activities = packageManager.queryIntentActivities(intent,        PackageManager.MATCH_DEFAULT_ONLY);boolean isIntentSafe = activities.size() > 0;
```#### 5.1.3 Start an Activity with the Intent#### 5.1.4 Show an App Chooser1. more than one app that responds to the intent2. use Intent to createChooser()`Intent.createChooser(intent, title);`### 5.2 Getting a Result from the Activity1. `startActivityForResult()`2. your activity receives result in the `onActivityResult()` callback#### 5.2.1 Start the Activity1. need to set int arg (request code)to StartActivityForResult#### 5.2.2 Receuve the Result1. requestCode 2. resultCode —— RESULT_OK, RESULT_CANCEL3.	override onActivityResult4.	Handle Data

```Uri contactUri = data.getData();String[] projection = {Phone.NUMBER};Cursor cursor = getContentResolver() .query(contactUri, projection, null, null, null); 需要从别的线程调用避免block，考虑CursorLoadercursor.moveToFirst();int column = cursor.getColumnIndex(Phone.NUMBER);String number = cursor.getString(column);```
### 5.3 Allowing Other Apps to Start your Activity#### 5.3.1 Add an Intent Filter1. action data(uri mimeType) category2. receive implicit intents, you must include CATEGORY_DEFAULT#### 5.3.2 Handle the Intent in your Activity

```Intent intent = getIntent();Uri data = intent.getData();if (intent.getType().indexOf("image/") != -1) {        // Handle intents with image data ...  } else if (intent.getType().equals("text/plain")) {        // Handle intents with text ...}
```
#### 5.3.3 Return a Result1. setResult

	```		// Create intent to deliver some kind of result data		Intent result = new Intent("com.example.RESULT_ACTION", Uri.parse("content://result_uri"));		setResult(Activity.RESULT_OK, result);		finish();
	```
	2. use result code to deliver an integer and no need set intent
	```	setResult(RESULT_COLOR_RED);	finish();
	```## 6	Working With System Permissions1.	System intergrity 系统公正2.	User s privacy 用户权限3.	Run app in a limited access sandbox 4.	Explicitly request permission 明确请求5.	Grant the permission 授予权限### 6.1 Declaring Permissions (AndroidManifest)——how sensitive[Permission](https://developer.android.com/training/permissions/declaring.html#perm-needed)
1.	automatically grant some permissions 自动授予2.	request when installing app(5.0-) or running app(6.0+)3.	use an intent 4.	put <uses-permission> element5.	System Permission API/Introduction### 6.2 Requesting Permissions at Run Time 6.0+,API 23+[training/permissions](https://developer.android.com/training/permissions/requesting.html)
1.	request when installing app(5.0-) or running app(6.0+)2.	streamline the app install process 简化安装过程3.	give users more control over the app s functionality控制功能4.	access to the camera but not the device location允许/不允许5.	revoke the permissions at anytime by Setting screen设置权限6.	sytem permissions divides into two categories, normal dangerousnormal ,request manifest, system automatically granteddangerous, approval to app, deny some permission but the app ran7.	check and requst permissions#### 6.2.1 Check for Permissions——dangerous

```// Assume thisActivity is the current activityint permissionCheck = ContextCompat.checkSelfPermission(thisActivity,        Manifest.permission.WRITE_CALENDAR);Return PackageManager.PERMISSION_GRANTED，PERMISSION_DENIED
```#### 6.2.2 Request Permissions——dangerous1. find situations to explaination 权限请求说明`shouldShowRequestPermissionRationale()`2. request permission—— stardard dialog box 请求

	```// Here, thisActivity is the current activityif (ContextCompat.checkSelfPermission(thisActivity,                Manifest.permission.READ_CONTACTS)        != PackageManager.PERMISSION_GRANTED) {    // Should we show an explanation?    if (ActivityCompat.shouldShowRequestPermissionRationale(thisActivity, Manifest.permission.READ_CONTACTS)) {// Show an explanation to the user *asynchronously* -- don't block // this thread waiting for the user's response! After the user // sees the explanation, try again to request the permission.} else {   // No explanation needed, we can request the permission.ActivityCompat.requestPermissions(thisActivity,                new String[]{Manifest.permission.READ_CONTACTS},                MY_PERMISSIONS_REQUEST_READ_CONTACTS);        // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an        // app-defined int constant. The callback method gets the        // result of the request.    }} 
	```
3. Handle the permissions request response 回调grant any other permissions in that group, read/wirte_Contacts同意一个，另一个Request时自动grantnot ask again, 下一次请求会直接deny
	``` @Overridepublic void onRequestPermissionsResult(int requestCode,        String permissions[], int[] grantResults) {    switch (requestCode) {        case MY_PERMISSIONS_REQUEST_READ_CONTACTS: {// If request is cancelled, the result arrays are empty.            if (grantResults.length > 0&& grantResults[0] == PackageManager.PERMISSION_GRANTED) {                // permission was granted, yay! Do the                // contacts-related task you need to do.  } else { // permission denied, boo! Disable the// functionality that depends on this permission.  }            return;        }// other 'case' lines to check for other        // permissions this app might request    }}
	```### 6.3 Permissions Usage Notes
1.	overwhelm a user with permission requests2.	frustrate to use, doing with the user s information3.	best practices#### 6.3.1 Consifer Using an Intent
1.	system prompts users to choose a camera app, `onAcvitiviyResult()`2.	Permission : control over UX but design an appropriate UIGrant once not request, but deny and unablet to perform operation3.	Intent: Don't design UI, not control over UXSystem prompt to choose an app, every time need to operation the dialog.#### 6.3.2 Only ask for Permissions you need1. minimize the number of permissions#### 6.3.3	Don't overwhelm the user1.	request permission as you need them, not request a lot#### 6.3.4 Explain why you need permissions
1. user puzzling2. app tutorial#### 6.3.5 Test for Both permission Models
1.	identify cur permissions and the related code path2.	Test user flows across premission-protected services and data3.	Test with various combinations of granted or revokes permission4.	Use adb`adb shell pm list permissions –d –g(group)adb shell pm [grant|revoke] <permission-name> … `5.	Analyze your app for services that use permissions