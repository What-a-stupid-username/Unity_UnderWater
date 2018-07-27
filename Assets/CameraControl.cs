using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour {

    

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

        float a = Input.GetAxis("Horizontal");
        if (a != 0)
        {
            transform.position += transform.right * a;
        }
        a = Input.GetAxis("Vertical");
        if (a != 0)
        {
            transform.position += transform.forward * a;
        }
    }
}
