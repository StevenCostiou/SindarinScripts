"
I regroup all debugging scripts written with the Sindarin debugging API to make them available for analysis.

Each method represents the copy of the source code of a script, and has a pragma indicating in which tool that script is used in production (if any).

My `sindarin` instance variable is an instance of the debugging API (class `SindarinDebugger`). 
All message sends to this variable represent a direct call to the API methods.

The scripts stored in this repository are not necessarily executable as is. They are merely here for documentation and study of the debugging API. Some of these scripts are executable and fully functionnal in their original context (for instance, the debugger). Some of them produce errors or are not correct (their unit tests fail) basically because developers were not able to achieve their goal with Sindarin.
"
Class {
	#name : #SindarinScriptRepository,
	#superclass : #Object,
	#instVars : [
		'sindarin'
	],
	#category : #SindarinScripts
}

{ #category : #initialize }
SindarinScriptRepository >> initialize [
	sindarin := SindarinDebugger new
]

{ #category : #stepping }
SindarinScriptRepository >> stepBytecodeScript [
	sindarin stepBytecode
]
