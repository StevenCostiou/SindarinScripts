"
I will step the execution from a context until the next call to the same object as that context's receiver.
"
Class {
	#name : #SindarinScriptStepToNextCallInObject,
	#superclass : #SindarinCommand,
	#instVars : [
		'debugger',
		'conditionValue'
	],
	#category : #SindarinScripts
}

{ #category : #initialization }
SindarinScriptStepToNextCallInObject class >> defaultIconName [
	^ #glamorousInto
]

{ #category : #hooks }
SindarinScriptStepToNextCallInObject >> execute [

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
SindarinScriptStepToNextCallInObject >> setConditionValue [

		conditionValue := debugger receiver
]

{ #category : #hooks }
SindarinScriptStepToNextCallInObject >> targetCondition [

	^ debugger receiver ~= conditionValue
]
