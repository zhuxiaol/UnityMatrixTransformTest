//=====================================================
// - FileName:      ScaleTransformation.cs
// - Created:       wangguoqing
// - UserName:      2018/07/22 17:24:14
// - Email:         wangguoqing@hehegames.cn
// - Description:   
// -  (C) Copyright 2008 - 2015, hehehuyu,Inc.
// -  All Rights Reserved.
//======================================================
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleTransformation : Transformation {

    public Vector3 scale;
    public override Matrix4x4 Matrix
    {
        get
        {
            Matrix4x4 matrix = new Matrix4x4();
            matrix.SetRow(0, new Vector4(scale.x, 0f, 0f, 0f));
            matrix.SetRow(1, new Vector4(0f, scale.y, 0f, 0f));
            matrix.SetRow(2, new Vector4(0f, 0f, scale.z, 0f));
            matrix.SetRow(3, new Vector4(0f, 0f, 0f, 1f));
            return matrix;
        }
    } 
    public  Vector3 Apply(Vector3 point)
    {
        point.x *= scale.x;
        point.y *= scale.y;
        point.z *= scale.z;
        return point;
    } 
}
