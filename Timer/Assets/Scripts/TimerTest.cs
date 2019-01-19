//=====================================================
// - FileName:      TimerTest.cs
// - Created:       codingriver
//======================================================

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimerTest : MonoBehaviour
{
	private Action cancelAcion;
	// Use this for initialization
	async void  Start () {
        Debug.Log("Start---------------------------"+Time.realtimeSinceStartup);
        await TimerMgr.Instance.WaitAsync(1000 * 3);
        Debug.Log("End---------------------------" + Time.realtimeSinceStartup);
		StartCoroutine(test());
		await TimerMgr.Instance.WaitAsync(1000 * 10,out cancelAcion);
		Debug.Log("End1---------------------------" + Time.realtimeSinceStartup);
	}


	IEnumerator test()
	{
		yield return new WaitForSeconds(5);
		if (cancelAcion != null)
		{
			
			Debug.Log("cancelAction 【codingriver】");
			cancelAcion();
		}
		
		
	}
	
	
	// Update is called once per frame
	void Update () {
		
	}
}
		