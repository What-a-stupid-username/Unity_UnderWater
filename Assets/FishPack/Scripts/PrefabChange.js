#pragma strict

import System.Collections.Generic;


var mPrefabs = new List.<GameObject>();

private var mIndex : int = 0;
private var mRefPos : Transform;
private var mActual : GameObject;

var mText : GUIText;


function Start ()
{
	mRefPos = gameObject.transform;
	Load();
}

function Update ()
{
	if ( Input.GetKeyDown( KeyCode.UpArrow ) )
	{		
		mIndex++;
		mIndex = Mathf.Abs( mIndex % mPrefabs.Count );
		Load();
	}
	if ( Input.GetKeyDown( KeyCode.DownArrow ) )
	{
		mIndex--;
		mIndex = Mathf.Abs( mIndex % mPrefabs.Count );
		Load();
	}
	
}

function Load()
{
	if ( mActual )
		DestroyImmediate( mActual );
	
	if ( mPrefabs.Count )
	{
		mActual = Instantiate( mPrefabs[ mIndex ] );
		mActual.transform.position = mRefPos.position;
		mActual.transform.rotation = mRefPos.rotation;
		
		if ( mText )
		{
			mText.text = mIndex + " " + mPrefabs[ mIndex ].name;
		}
	}
	//Debug.Log( "index of loaded prefab : " + mIndex );
}
