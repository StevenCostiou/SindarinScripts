"
I will step the execution until a class is instantiated
"
Class {
	#name : #SindarinScriptStepToNextInstanceCreation,
	#superclass : #SindarinCommand,
	#instVars : [
		'errorString',
		'maxDepth'
	],
	#category : #SindarinScripts
}

{ #category : #initialization }
SindarinScriptStepToNextInstanceCreation class >> defaultIconName [
	^ #smallNew
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation class >> defaultMaxDepth [
	^1000
]

{ #category : #default }
SindarinScriptStepToNextInstanceCreation class >> defaultName [
	<toolbarExtensionDebugCommand: 50>
	<codeExtensionDebugCommand: 50>
	^ 'Next instance creation'
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> errorDuringSearchString [

	^ 'Search interrupted due to exception.'
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> errorString [
	^errorString
]

{ #category : #executing }
SindarinScriptStepToNextInstanceCreation >> execute [

	| debugger sender depth |
	debugger := self debuggerPresenter sindarinDebugger.
	self debuggerPresenter removeSessionHolderSubscriptions.
	sender := debugger context sender.

	depth := 0.
	errorString := nil.
	debugger step.
	[ debugger isAboutToInstantiateClass or: [ errorString notNil ] ] 
		whileFalse: [ 
			debugger step.
			depth := depth + 1.
			depth = self maxDepth ifTrue: [ errorString := self notFoundErrorString ].
			debugger context == sender ifTrue: [ 
				errorString := self notFoundInCurrentContextString ].
			debugger hasSignalledUnhandledException ifTrue: [ 
				errorString := self errorDuringSearchString ] ].

	self debuggerPresenter
		setSessionHolderSubscriptions;
		forceSessionUpdate.

	errorString ifNotNil: [ 
		self debuggerPresenter
			warning: errorString
			for: self debuggerPresenter toolbar ]
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> maxDepth [

	^ maxDepth ifNil: [ maxDepth := self class defaultMaxDepth ]
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> maxDepth: anObject [

	maxDepth := anObject
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> notFoundErrorString [

	^ 'No instance creation found in 1000 debugger steps: try again to continue your search.'
]

{ #category : #accessing }
SindarinScriptStepToNextInstanceCreation >> notFoundInCurrentContextString [

	^ 'No instance creation found in this context.'
]
