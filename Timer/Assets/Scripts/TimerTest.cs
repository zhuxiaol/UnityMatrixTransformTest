//=====================================================
// - FileName:      TimerTest.cs
// - Created:       codingriver
//======================================================

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimerTest : MonoBehaviour {

	// Use this for initialization
	async void  Start () {
        Debug.Log("Start---------------------------"+Time.realtimeSinceStartup);
        await ETModel.TimerMgr.Instance.WaitAsync(1000 * 3);
        Debug.Log("End---------------------------" + Time.realtimeSinceStartup);
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
