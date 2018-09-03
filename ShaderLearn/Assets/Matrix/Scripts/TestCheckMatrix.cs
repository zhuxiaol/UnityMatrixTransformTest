//=====================================================
// - FileName:      TestCheckMatrix.cs
// - Created:       wangguoqing
// - UserName:      2018/09/03 17:18:56
// - Email:         wangguoqing@hehegames.cn
// - Description:   
// -  (C) Copyright 2008 - 2015, hehehuyu,Inc.
// -  All Rights Reserved.
//======================================================
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestCheckMatrix : MonoBehaviour {

    // Use this for initialization

    void Start()
    {
        cam = Camera.main;
        CheckMatrix();
        CheckFromModelSpaceToViewportSpace();

    }
    Camera cam = Camera.main;
    Matrix4x4 mat;
    /// <summary>
    /// 
    /// </summary>
    void CheckMatrix()
    {
        

        //检查 透视裁剪矩阵
        mat = TransformationMatrixUtil.VToPMatrix();
        Debug.Log(mat);
        Debug.Log(cam.projectionMatrix);
        Debug.Log(cam.previousViewProjectionMatrix);
        Debug.Log("mat == cam.projectionMatrix::" + (mat == cam.projectionMatrix));


        //检查世界空间到观察空间
        mat = TransformationMatrixUtil.WToVMatrix();
        Debug.Log(mat);
        Debug.Log(mat.inverse);
        Debug.Log(cam.worldToCameraMatrix);
        Debug.Log(cam.cameraToWorldMatrix);
        Debug.Log("mat == cam.worldToCameraMatrix::" + (mat == cam.worldToCameraMatrix));

        //检查世界空间到模型空间
        Transform t = Camera.main.transform;
        mat = TransformationMatrixUtil.MToWMatrix(t.localScale, t.localEulerAngles, t.localPosition).inverse;
        Debug.Log(mat);
        Debug.Log(t.worldToLocalMatrix);
        Debug.Log("mat == t.worldToLocalMatrix::" + (mat == t.worldToLocalMatrix));


        //cam.WorldToViewportPoint();

        Debug.Log(cam.cullingMatrix);
        Debug.Log(cam.nonJitteredProjectionMatrix);//cam.nonJitteredProjectionMatrix和cam.projectionMatrix 透视矩阵相等

    }

    public Transform trans1;
    void CheckFromModelSpaceToViewportSpace()
    {

        Transform _parent = trans1.parent;
        //模型空间转世界空间
        Vector3 p = TransformationMatrixUtil.MToWPosition(_parent.localScale, _parent.localEulerAngles, _parent.localPosition, trans1.localPosition);
        //世界空间转观察空间
        Vector3 viewPos = TransformationMatrixUtil.WToVPosition(p);

        //观察空间转透视裁剪空间
        Vector4 clipPos = TransformationMatrixUtil.VToPPosition(viewPos);
        //裁剪空间转NDC
        Vector4 ndcPos= TransformationMatrixUtil.PToNDCPosition(clipPos);

        Vector4 viewportPos = TransformationMatrixUtil.NDCToTexturePosition(ndcPos);

        Vector4 screenPos = TransformationMatrixUtil.TextureToScreenPosition(viewportPos);

        Debug.Log(viewportPos.z);
        Debug.Log(viewportPos.w);
        Debug.LogFormat("screenPos:{0},viewportPos:{1},clipPos:{2},viewPos:{3}", screenPos, viewportPos, clipPos, viewPos);
        Debug.Log( cam.WorldToViewportPoint(trans1.position));
        Debug.Log( cam.WorldToScreenPoint(trans1.position));
    }

    
    // Update is called once per frame
    void Update () {
        
    }
}
