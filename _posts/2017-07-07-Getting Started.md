---
layout: post
title: Getting Started
category: Training
tags: [Getting Started]
---

[Develop/Training/Getting Started](https://developer.android.com/training/index.html)


### 1.4 Start Another Activity

3. [Guides/App Resources](https://developer.android.com/guide/topics/resources/index.html)
2. Android/Dashboards ——

```
```
	```
	```



```



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





	```
	```


```
```

```


```
```


	```
	```
	

	```



```
```

	```
	```


	```



