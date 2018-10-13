//=====================================================
// - FileName:      TestMatrix.cs
// - Created:       wangguoqing
// - UserName:      2018/09/03 17:18:56
// - Email:         wangguoqing@hehegames.cn
// - Description:   
// -  (C) Copyright 2008 - 2015, codingriver,Inc.
// -  All Rights Reserved.
//======================================================
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 测试空间变换
/// 这里是透视相机，没有做正交相机的
/// </summary>
public class TestMatrix : MonoBehaviour {

    // Use this for initialization
    Camera cam;

    /// <summary>
    /// 模型空间的物体，localPosition作为模型空间的坐标
    /// 父物体的Transform作为世界空间对模型空间的变换
    /// </summary>
    public Transform trans1;
    void Start()
    {
        cam = Camera.main;
        TestModelSpaceToWorldSpace();
        //TestWorldSpaceToModelSpace();
        //TestWorldSpaceToViewSpace();
        //TestViewSpaceToClipSpace();
        //TestModelSpaceToScreenSpace();
    }
    

    /// <summary>
    /// 模型空间转世界空间的坐标
    /// </summary>
    void TestModelSpaceToWorldSpace()
    {
        Transform _parent = trans1.parent;
        //模型空间转世界空间
        Vector3 p = TransformationMatrixUtil.MToWPosition(_parent.localScale, _parent.localEulerAngles, _parent.localPosition, trans1.localPosition);
        Debug.Log("模型空间转世界空间的坐标：" + p);
        Debug.Log("物体的世界坐标" + trans1.position);
        //模型空间转世界空间
        Matrix4x4 matrix = TransformationMatrixUtil.MToWMatrix(_parent.localScale, _parent.localEulerAngles, _parent.localPosition);
        Debug.LogFormat("matrix:\n{0}\n\nlocalToWorldMatrix:\n{1}\n\n是否相等：{2}", matrix, _parent.localToWorldMatrix, matrix == _parent.localToWorldMatrix);
    }
    /// <summary>
    /// 世界空间到模型空间变换对比
    /// 这里直接对比变换矩阵是否相同
    /// </summary>
    void TestWorldSpaceToModelSpace()
    {
        //检查世界空间到模型空间
        Transform _parent = trans1.parent;
        //模型空间转世界空间
        Matrix4x4 matrix = TransformationMatrixUtil.MToWMatrix(_parent.localScale, _parent.localEulerAngles, _parent.localPosition);
        //世界空间转模型空间；就是matrix的逆矩阵
        matrix = matrix.inverse;
        Debug.LogFormat("matrix:\n{0}\n\nworldToLocalMatrix:\n{1}\n\n是否相等：{2}", matrix, _parent.worldToLocalMatrix, matrix== _parent.worldToLocalMatrix);
        

    }

    /// <summary>
    /// 世界空间到观察空间变换对比
    /// 这里是透视相机，没有做正交相机的
    /// </summary>
    void TestWorldSpaceToViewSpace()
    {
        //注意这里是透视相机，没有做正交相机变换矩阵
        cam = Camera.main;
        //世界空间坐标到观察空间坐标
        Vector3 viewPos = TransformationMatrixUtil.WToVPosition(trans1.position);
        //结果是z轴相反，因为世界空间是左手坐标系，而观察空间是右手坐标系
        Debug.LogFormat("世界空间:{0},观察空间:{1}", trans1.position, viewPos);
        //世界空间到观察空间
        Matrix4x4 matrix = TransformationMatrixUtil.WToVMatrix();
        Debug.LogFormat("matrix:\n{0}\n\n worldToCameraMatrix:\n{1}\n\n是否相等：{2}", matrix, cam.worldToCameraMatrix, matrix == cam.worldToCameraMatrix);
    }

    /// <summary>
    /// 测试观察空间到裁剪空间的变换矩阵
    /// 注意这里是透视相机，没有做正交相机变换矩阵
    /// </summary>
    void TestViewSpaceToClipSpace()
    {
        //观察空间到裁剪空间矩阵，注意这里是透视相机，没有做正交相机变换矩阵
        Matrix4x4 matrix = TransformationMatrixUtil.VToPMatrix();
        Debug.LogFormat("matrix:\n{0}\n\n projectionMatrix:\n{1}\n\n是否相等：{2}", matrix, cam.projectionMatrix, matrix == cam.projectionMatrix);
    }

    /// <summary>
    /// 测试模型空间到屏幕空间的变换
    /// 只验证 屏幕坐标xy，不验证zw
    /// 注意这里是透视相机，没有做正交相机变换矩阵
    /// </summary>
    void TestModelSpaceToScreenSpace()
    {
        Transform _parent = trans1.parent;
        //模型空间转世界空间
        Vector3 worldPos = TransformationMatrixUtil.MToWPosition(_parent.localScale, _parent.localEulerAngles, _parent.localPosition, trans1.localPosition);
        //世界空间转观察空间
        Vector3 viewPos = TransformationMatrixUtil.WToVPosition(worldPos);
        //观察空间转透视裁剪空间
        Vector4 clipPos = TransformationMatrixUtil.VToPPosition(viewPos);
        //裁剪空间到屏幕空间变换
        Vector4 screenPos = TransformationMatrixUtil.PToScreenPosition(clipPos);

        Vector4 screenPos1 = cam.WorldToScreenPoint(trans1.position);
        //Vector4 viewportPos = cam.WorldToViewportPoint(trans1.position);
        Debug.LogFormat(" worldPos:{0},trans1.positon:{1}\n viewPos:{2}\n clipPos:{3}\n screenPos:{4},screenPos1:{5}",worldPos,trans1.position,viewPos,clipPos,screenPos,screenPos1);
        
    }
}
