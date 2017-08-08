---
layout: post
title: Multimedia
category: Training
tags: [Multimedia]
---

[Building Apps with Graphics & Animation](https://developer.android.com/training/building-graphics.html)


## 1 Displaying Graphics with OpenGL ES

## 2 Animating Views Using Scenes and Transitions
1. user input and other events
2. provide visual continuity between view hierarchies
3. give users feedback and help them learn how your app works
4. transitions framework

### 2.1 The Transitions Framework
1. main features and components
2. features: 
	* Group-level animations
	* Transition-based animation
	* Built-in animations
	* Resource file support
	* Lifecycle callbacks

#### 2.1.1 Overview
1. many scenes —— view(layout), from a scenes to another scene
2. view hierarchies
3. start and end scene
4. `TransitionManager`

#### 2.2.2 Scenes
1. a view hierarchy is a any(simple or complex) view
2. generate a view hierarchy dynamically at runtime
3. scene root 
4. [create a scene](https://developer.android.com/training/transitions/scenes.html)

#### 2.2.3 Transitions
1. animations create a series of frames
2. the frames depict a change between the view hierarchies of starting and ending scenes
3. `Transition ` Object stores the animation, using a `TransitionManager` to apply the object
4. transition between different scenes or a different state of current scene




### 2.2 Creating a Scene
1. store the state of a view hierarchy

#### 2.2.1 Create s Scene From a Layout Resource
1. create `Scene` object from a layout res
2. retrieve the scene root from a layout as a ViewGroup instance
3. `Scene.getSceneForLayout()` 

#### 2.2.2 Define Layouts for Scenes
1. create two different scenes with the same scene root element
2. load mulituple unrelated scene objects 
3. layout definitions:
	* main layout with a child layout
	* the first scene layout with one text, named "first_scene.xml"
	* the second scene layout with another text, named "second_scene.xml" 
	
```
<LinearLayout>
	<FrameLayout android:id="@+id/scene_ root>
		<include layout="@layout/a_scene />
	</FrameLayout>
</LinearLayout>

```

#### 2.2.3 Generate Scenes from Layouts

```
ViewGroup root = (ViewGroup) findViewById(R.id.scene_root);
Scene fristScene = Scene.getSceneForLayout(root, R.layout.first_scene, this);
Scene secondScene = Scene.getSceneForLayout(root, R.layout.second_scene, this);

```

#### 2.2.4 Create a Scene in Your Code
1. use `Scene(sceneRoot, viewHierarchy)`

```
// Obtain the scene root element
ViewGroup sceneRoot = (VIewGroup) mSomeLayoutElement;
// Obtain the view hierarchy to add as a child of the scene root when this scene id entered
ViewGroup viewHierarchy = (ViewGroup) someOtherLayoutElement;
Scene scene = new Scene(sceneRoot, viewHierarchy);
```

#### 2.2.5 Create Scene Actions
1. `setEnter/ExitAction()`
2. call `setExitAction()` on the starting scene before running the tranistion animation
3. call `setEnterAction()` on the ending scene after running the transition animation


### 2.3 Applying a Transition
1. apply a transition between two scenes if a view hierarchy
2. animtions create a series of frames of hierarchies chanegs
3. animations as transition objects
4. run a animation between two scenes using built-in transitions to move, resize and fade views

#### 2.3.1 Create a Transition
1. Create a transition instance from a res file
	* `res/transition/fade_transition.xml`

	```
	<transitionSet android:transitonOrdering="sequential">
		<fade android:fadingMode="fade-out" />
		<changeBounds />
		<fade android:fadingMode="fade_in />
	</tranistionSet>
	```
	
	* inflate a Transition instance inside your activty from a res file
	
	```
	Transition fadeTransition = TransitionInflater.from(this).inflateTransition(R.transition.fade_transition);
	```
	
2. create a transition instance in your code
	 
	 ``` Transition fadeTransition = new Fade(); ```
	 

#### 2.3.2 Apply a Transition


``` TransitionManager.go(scene, fadeTransition); ```

### 2.4 Creating Custom Transitions

## 3 Adding Animations
### 3.1 Crossfading Two Views
### 3.2 Using ViewPager for Screen Sildes
### 3.3 Zooming a View
### 3.4 Animating Layout Changes

