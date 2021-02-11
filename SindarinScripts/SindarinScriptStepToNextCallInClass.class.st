"
I will step the execution from a context until the next call to the same class as that context's receiver's class.
"
Class {
	#name : #SindarinScriptStepToNextCallInClass,
	#superclass : #SindarinCommand,
	#instVars : [
		'debugger',
		'conditionValue'
	],
	#category : #SindarinScripts
}

{ #category : #initialization }
SindarinScriptStepToNextCallInClass class >> defaultIconName [
	^ #glamorousInto
]

{ #category : #hooks }
SindarinScriptStepToNextCallInClass >> execute [

	| callingMethod maxDepth depth |
	self context removeSessionHolderSubscriptions.
	debugger := self context sindarinDebugger.
	self setConditionValue.
	callingMethod := debugger method.
	debugger step.

	maxDepth := 1000.
	depth := 0.
	[ 
	debugger method ~= callingMethod and: [ 
		depth < maxDepth and: [ self targetCondition ] ] ] 
		whileTrue: [ 
			debugger step.
			depth := depth + 1.
			debugger hasSignalledUnhandledException ifTrue: [ depth := 1000 ] ].

	self context
		setSessionHolderSubscriptions;
		forceSessionUpdate
]

{ #category : #hooks }
SindarinScriptStepToNextCallInClass >> setConditionValue [

	conditionValue := debugger receiver class
]

{ #category : #hooks }
SindarinScriptStepToNextCallInClass >> targetCondition [

	^debugger receiver class ~= conditionValue
]
