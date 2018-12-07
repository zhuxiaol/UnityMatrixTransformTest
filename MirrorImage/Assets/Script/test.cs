//=====================================================
// - FileName:      test.cs
// - Created:       codingriver
//======================================================

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using UnityEngine;

public class test : MonoBehaviour {




	// Use this for initialization
	void Start () {
        Resources.Load("sample1");
        Resources.Load("sample2");
        StartCoroutine(StartTest());
    }
	
	// Update is called once per frame
	void Update () {
		
	}

    IEnumerator StartTest()
    {
        yield return new WaitForSeconds(2);
        load("sample1");
        yield return new WaitForSeconds(2);
        load("sample2");
        yield return new WaitForSeconds(2);
        load("sample1");
        load("sample2");
        load("sample1");
        load("sample2");
        load("sample1");
        load("sample2");
        yield break;
    }


    public void load(string name)
    {
        Stopwatch stopwatch = new Stopwatch();
        Object asset= Resources.Load(name);
        stopwatch.Start();
        for (int i = 0; i < 10000; i++)
        {
            var obj= GameObject.Instantiate(asset) as GameObject;
            //obj.transform.SetParent(transform);
        }
        stopwatch.Stop();
        UnityEngine.Debug.Log(name+"    "+stopwatch.ElapsedMilliseconds);
        System.IO.File.AppendAllText(Application.persistentDataPath + "/test.txt", name + "    " + stopwatch.ElapsedMilliseconds+"\n");
    }
}
