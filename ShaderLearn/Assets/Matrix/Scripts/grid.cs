using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class grid : MonoBehaviour {

    //public Vector3 scale=Vector3.one;
    //public Vector3 rotation;
    //public Vector3 translate;
    public Vector3 pos;
    
	// Use this for initialization


	void Start1 () {
        MeshFilter mf= GetComponent<MeshFilter>();
        Mesh mesh = mf.mesh;
        foreach (var item in mesh.vertices)
	{
        Debug.Log(item);
	} 

        Vector3 p= TransformationMatrixUtil.MToWPosition(transform.localScale, transform.localEulerAngles, transform.localPosition, pos);
        GameObject obj= GameObject.CreatePrimitive(PrimitiveType.Cube);
        obj.transform.position = p;
        obj.transform.localScale = Vector3.one * 0.1f;

        Transform t= Camera.main.transform;

        p = TransformationMatrixUtil.WToMPosition(t.localScale, t.localEulerAngles, t.localPosition, p);

        //p = TransformationMatrixUtil.TransformPosition(transform.parent.localScale, transform.parent.localEulerAngles, transform.parent.localPosition, p);
        Debug.Log("p:" + p);
        Debug.Log("worldPos:" + transform.GetChild(0).position);



	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
