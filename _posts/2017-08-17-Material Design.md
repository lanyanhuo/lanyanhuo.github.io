---
layout: post
title: UI——Material Design
category: Training
tags: [UI——Material Design]
---

[Material Design for Developer](https://developer.android.com/training/material/index.html)

1. guide for visual, motion, and interaction design
2. [material design specification](https://material.io/guidelines/material-design/introduction.html#)
3. [material degisn io](https://material.io)



## 1 Get Stared
1. `theme, layouts, elevation, widgets, animation`


### 1.1 Apply the Material Theme
1. specify a style inheriting from `android:Theme.Material`
2. provide updated system widgets that let you set color palette and default animations

	```
	<!-- res/values/styles.xml -->
	<style name="AppTheme" parent="android:Theme.Material" />
	```

### 1.2 Design Your Layouts
1. conform to the `material design guidelines`
2. pay attention to the following : `Baseline grids, Keylines, Spacing, Touch target size, Layout structure`

### 1.3 Specify Elevation in Your Views
1. `android:elevation="5dp"` to determine the size of view's shadow and its drawing order
2. elevation changes when [responding to touch gesture](https://developer.android.com/training/material/animations.html#ViewState)

### 1.4 Create Lists and Cards
1. create `android.support.v7.widget.CardView` and set `card_view:cardCornerRadius` to show pieces of information inside cards with a consistent look across apps

### 1.5 Customize Your Animations
1. `startActivity(intent, ActivityOptions.makeSceneTransitionAnimation(this).toBundle());`


## 2 Using the Material Theme
1. apply md styles
2. provide : system widgets for color palette, touch feedback animations for system widgets and activity tranistion animations
3. material theme : `Theme.Material`(dark version), `Theme.Material.Light`(light version), `Theme.Material.Light.DarkActionBar`
4. [v7 Support Libraries](https://developer.android.com/tools/support-library/features.html#v7)

### 2.1 Customize the Color Palette

```
<!-- inherit from the material theme -->
  <style name="AppTheme" parent="android:Theme.Material">
    <!-- Main theme colors -->
    <!--   your app branding color for the app bar -->
    <item name="android:colorPrimary">@color/primary</item>
    <!--   darker variant for the status bar and contextual app bars -->
    <item name="android:colorPrimaryDark">@color/primary_dark</item>
    <!--   theme UI controls like checkboxes and text fields -->
    <item name="android:colorAccent">@color/accent</item>
  </style>
```

### 2.2 Customize the Status Bar
1. specify a color to fit your brand and provide enough contrast to show the white status icons
2. `android:statusBarColor` inherits the value of `android:colorPrimaryDark`
3. `Window.setStatusBarColor()`
4. [customize the material theme](https://developer.android.com/training/material/images/ThemeColors.png)

### 2.3 Theme Individual Views
1. specify `android:theme`


## 3 Creating Lists and Cards 
1. with a consisitent look and feel using system widget
2. use `RecyclerView, CardView` to create complex lists and cars with md styles

### 3.1 Create Lists
1. create `RecyclerView`, built-in layout managers : `LinearLayoutManager`, `GridLayoutManager` and `StaggeredGridLayoutManager`
2. create an adapter that extends `RecyclerView.Adapter<RecyclerView.ViewHolder>`
3. customize these animations extend the `RecyclerView.ItemAnimator` or use `RecyclerView.setItemAnimator()`

### 3.2 Create Cards
1. `CardView` extends the `FrameLayout` class
2. `CardView` widgets can have shadows and rounded corners
3. [CardView](https://developer.android.com/reference/android/support/v7/widget/CardView.html)

### 3.3 Add Depenencies
1. `compile 'com.android.support:cardview-v7:21.0.+' `, 
    `compile 'com.android.support:recyclerview-v7:21.0.+'`


## 4 Defining Shadows and Clipping Views
1. create elevation for your views
2. focus user's attention to the task at hand
3. views with higher Z values cast larger, softer shadows
4. view clipping
5. [Objects in 3D space](https://material.io/guidelines/material-design/elevation-shadows.html)

### 4.1 Assign Elevation to Your Views
1. Z = elevation + translationZ
2. `android:elevation` or `View.setElevation()` to set the elevation of a view
3. `View.setTranslationZ()` to set the translation of a view, or `ViewPropertyAnimatior.translationZ()`

### 4.2 Customize View Shadows and Outlines
1. the bounds of a view's background drawable determine the dafault shape of its shadow, `android:background`
2. `Outlines` represent the outer shape of a graphics object and define the ripple area for touch feedback
3. verride default shape of the view's shadow, define a custom outline for a view :
	* extend the `ViewOutlineProvider` class
	* override the `getOutline()` method
	* `View.setOutlineProvider()` to assign the outline provider
4. create oval and rect outlines with rounded corners using `Outline` class

### 4.3 Clip Views
1. easily change the shape of a view, use `View.setClipToOutline()` or `android:clipToOutline`
2. `Outline.canClip()` to create rectangle, circle, and round rectangle outlines
3. `View.setClipToOutline()` to set the background drawable
4. `RevealEffect` animation


## 5 Working with Drawable
1. create vector drawable and tinit drawable resources

### 5.1 Tint Drawable Resources
1. tint bitmaps, nine-patches defined as alpha mask
2. `BitmapDrawable`, `NinePatchDrawable` and `VectorDrawable` with `setTint()`
3. `android:tint`, `android:tintMode`

### 5.2 Extract Prominent Colors from an Image
1. extract colors : vibrant, muted
2. `Palette.generate()` or `Palette.generateAsync()`
3. depenencies `compile 'com.android.support:palette-v7:21.0.0'`
4. [Palette](https://developer.android.com/reference/android/support/v7/graphics/Palette.html)

### 5.3 Create Vector Drawables
1. `SVG Path reference`
2. `Animating Vector Drawable`


## 6 Defining Custom Animations
1. transitions with shared elements

## 7 Maintaining Compatibility

### 7.1 Define Alternative Styles
1. older theme `res/values/styles.xml`
2. md theme `res/values-v21/styles.xml`

### 7.2 Provide Alternative Layouts
1. res/layout-21/xx

### 7.3 Use the Support Library
1. API21+ `RecyclerView`, `CardView`, `Palette`

#### 7.3.1 System widgets
1. `Theme.AppCompat` themes provide MD styles for `EditText, Spinner, Checkbox, RadioButton, SwitchCompat, CheckedTextView`


#### 7.3.2 Color Palette

```
<!-- extend one of the Theme.AppCompat themes -->
<style name="Theme.MyTheme" parent="Theme.AppCompat.Light">
    <!-- customize the color palette -->
    <item name="colorPrimary">@color/material_blue_500</item>
    <item name="colorPrimaryDark">@color/material_blue_700</item>
    <item name="colorAccent">@color/material_green_A200</item>
</style>
```

#### 7.3.3 Lists and Cards
1. `RecylerView` and `CardView`

#### 7.3.4 Dependencies

```
dependencies {
    compile 'com.android.support:appcompat-v7:26.0.1'
    compile 'com.android.support:cardview-v7:26.0.1'
    compile 'com.android.support:recyclerview-v7:26.0.1'
}
```

### 7.4 Check the System Version
1. Activity transitions
2. Touch feedback
3. Reveal animations
4. Path-based animations

## 8 Selecting Colors with the Palette API
1. select colors using the v7 Palette library




## 9 Using the Design Support Library
1. create components including the navigation drawer

### 9.1 Add the Dependency
`compile 'com.android.support:design:26.0.1' `

### 9.2 Create a Floating Action Button
1. `FloatingActionButton` ——FAB extends `ImageButton`
2. customize a variety of aspects of the button, including its size, placement, and appearance

### 9.3 Create a Navigation Drawer
1. a drawer layout
2. a drawer header layout
3. a drawer menu layout

