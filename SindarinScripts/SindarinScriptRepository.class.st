"
I regroup all debugging scripts written with the Sindarin debugging API to make them available for analysis.

Each method represents the copy of the source code of a script, and has a pragma indicating in which tool that script is used in production (if any).

My `sindarin` instance variable is an instance of the debugging API (class `SindarinDebugger`). 
All message sends to this variable represent a direct call to the API methods.

My `tool` instance variable represent the tool using a script, and that the script needs to access.

The scripts stored in this repository are not necessarily executable as is. They are merely here for documentation and study of the debugging API. Some of these scripts are executable and fully functionnal in their original context (for instance, the debugger). Some of them produce errors or are not correct (their unit tests fail) basically because developers were not able to achieve their goal with Sindarin.
"
Class {
	#name : #SindarinScriptRepository,
	#superclass : #Object,
	#instVars : [
		'sindarin',
		'tool'
	],
	#category : #SindarinScripts
}

{ #category : #skipping }
SindarinScriptRepository >> breakOnAFamilyOfMethods [

	[ sindarin isExecutionFinished ] whileFalse: [ 
		(('.*open.*File.*' match: sindarin selector) and: [ 
			 (sindarin context arguments at: 1) = 'myFile.txt' ]) ifTrue: [ 
			sindarin setBreakpointOn: sindarin context sender method ].
		sindarin step ]
]

{ #category : #skipping }
SindarinScriptRepository >> controlFlowBreakpoint [

	sindarin stepUntil: [ 
		sindarin method = Object >> #trySaveAs: and: [ 
			(sindarin context sender method = Object >> #actionPerformed:) not ] ]
]

{ #category : #skipping }
SindarinScriptRepository >> controlFlowBreakpointOnStack [

	sindarin stepUntil: [ 
		sindarin method = Object >> #trySaveAs: and: [ 
			(sindarin stack anySatisfy: [ :ctx | 
				 ctx method = Object >> #actionPerformed: ]) not ] ]
]

{ #category : #skipping }
SindarinScriptRepository >> divergenceStep [

	| sindarin1 sindarin2 |
	sindarin1 := SindarinDebugger debug: [ Object run ].
	sindarin2 := SindarinDebugger debug: [ Object run ].
	[ sindarin1 method = sindarin2 method ] whileFalse: [ 
		sindarin1 step.
		sindarin2 step ]
]

{ #category : #initialize }
SindarinScriptRepository >> initialize [
	sindarin := SindarinDebugger new
]

{ #category : #skipping }
SindarinScriptRepository >> objectCentricBreakpoint [

	| bpoint atom drawer |
	bpoint := sindarin setBreakpointOn: Object >> #displayAtom:.
	bpoint whenHit: [ 
		sindarin stepOver.
		atom := sindarin messageReceiver.
		drawer := sindarin messageArguments first.
		(atom shape isCircular and: [ atom shape radius > 50 ]) ifTrue: [ 
			sindarin haltOnCallTo: drawer.
			bpoint remove ].
		sindarin continue ]
]

{ #category : #skipping }
SindarinScriptRepository >> objectReplay [

	| bpoint atom drawer replayPoint drawerNode replayCondition |
	bpoint := sindarin setBreakpointOn: Object >> #displayAtom:.
	bpoint whenHit: [ 
		drawerNode := sindarin node.
		sindarin stepOver.
		drawer := sindarin messageArguments first.
		replayCondition ifTrue: [ 
			bpoint remove.
			replayPoint := sindarin setBreakpointOn: drawerNode.
			replayPoint whenHit: [ 
				sindarin skipWith: drawer.
				sindarin continue ] ].
		sindarin continue ]
]

{ #category : #skipping }
SindarinScriptRepository >> skipThroughNodeScript [

	| targetNode |
	targetNode := sindarin bestNodeFor:
		              tool code nonEmptySelectionInterval.
	sindarin skipThroughNode: targetNode
]

{ #category : #skipping }
SindarinScriptRepository >> skipUpToNodeScript [

	| targetNode |
	targetNode := sindarin bestNodeFor:
		              tool code nonEmptySelectionInterval.
	sindarin skipUpToNode: targetNode
]

{ #category : #'stepping - echo' }
SindarinScriptRepository >> stepBatchAndReturnNodeHashAndStackSize [

	"For EchoDebugger"

	| nodesHashAndStackSize count |
	count := 0.
	nodesHashAndStackSize := OrderedCollection new.
	[ 
	[ count <= 1000 ] whileTrue: [ 
		count := count + 1.
		nodesHashAndStackSize add: { 
				sindarin node dictionaryRepresentation hash.
				sindarin stack size }.
		sindarin step ] ]
		on: DebuggedExecutionException
		do: [ "when debugged execution is over or signals exception, stop and return the result data" 
			^ nodesHashAndStackSize ].
	^ nodesHashAndStackSize
]

{ #category : #skipping }
SindarinScriptRepository >> stepBeforeMessageSend [

	sindarin stepUntil: [ 
		sindarin node isMessage and: [ sindarin messageReceiver = nil ] ]
]

{ #category : #stepping }
SindarinScriptRepository >> stepBytecodeScript [
	sindarin stepBytecode
]

{ #category : #'steping - MKI' }
SindarinScriptRepository >> stepIt [
	"Executes the next instruction. If the instruction is a message-send, step inside it."
	sindarin signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	sindarin signalExceptionIfDebuggedExecutionIsFinished.
	sindarin debugSession stepItInto.
   sindarin	stepHooks do: [ :aBlock | aBlock value ]
]

{ #category : #stepping }
SindarinScriptRepository >> stepOverScript [
	sindarin stepOver
]

{ #category : #stepping }
SindarinScriptRepository >> stepScript [
	sindarin step
]

{ #category : #skipping }
SindarinScriptRepository >> stepThroughPitons: anArray [

	anArray do: [ :aMethod | 
		sindarin stepUntil: [ sindarin method = aMethod ] ]
]

{ #category : #stepping }
SindarinScriptRepository >> stepToMethodEntryScript [
	sindarin stepToMethodEntry
]

{ #category : #skipping }
SindarinScriptRepository >> stepToNextIteration [

	| blockClosure lastCtx |
	sindarin stepUntil: [ sindarin method = (Collection >> #collect:) ].
	blockClosure := sindarin arguments first.
	sindarin stepUntil: [ :ctx | 
		lastCtx ~~ ctx and: [ ctx method = blockClosure ] ].
	lastCtx := sindarin currentContext
]

{ #category : #stepping }
SindarinScriptRepository >> stepToReturnScript [
	sindarin stepToReturn
]

{ #category : #skipping }
SindarinScriptRepository >> stepUntilAssignment [

	sindarin stepUntil: [ 
		sindarin node isAssignment and: [ 
			sindarin assignmentValue == 42 and: [ 
				sindarin assignmentVariableName = #foo and: [ 
					sindarin receiver isKindOf: Object ] ] ] ]
]

{ #category : #'steping - MKI' }
SindarinScriptRepository >> stepUntilConditionIsTrue: aBlock [

	"The recording mechanics is included here.. may not the best place"
	self stDebugger removeSessionHolderSubscriptions.
	aBlock whileFalse: [ 
		| conditionValue |
		conditionValue := aBlock value.
		conditionValue ifFalse: [ 
			sindarin stepIt.
			self recordStep ].

		conditionValue ].
	self stDebugger setSessionHolderSubscriptions.
	self stDebugger forceSessionUpdate
]

{ #category : #skipping }
SindarinScriptRepository >> stepUntilException [

	sindarin stepUntil: [ 
		sindarin node isMessage and: [ 
			sindarin messageSelector = #signal and: [ 
				sindarin messageReceiver isKindOf: Exception ] ] ]
]
