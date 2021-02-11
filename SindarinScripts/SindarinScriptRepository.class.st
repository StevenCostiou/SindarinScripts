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

{ #category : #initialize }
SindarinScriptRepository >> initialize [
	sindarin := SindarinDebugger new
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

{ #category : #stepping }
SindarinScriptRepository >> stepBytecodeScript [
	sindarin stepBytecode
]

{ #category : #stepping }
SindarinScriptRepository >> stepOverScript [
	sindarin stepOver
]

{ #category : #stepping }
SindarinScriptRepository >> stepScript [
	sindarin step
]

{ #category : #stepping }
SindarinScriptRepository >> stepToMethodEntryScript [
	sindarin stepToMethodEntry
]

{ #category : #stepping }
SindarinScriptRepository >> stepToReturnScript [
	sindarin stepToReturn
]
