//=====================================================
// - FileName:      Transformation.cs
// - Created:       wangguoqing
// - UserName:      2018/07/22 17:17:46
// - Email:         wangguoqing@hehegames.cn
// - Description:   
// -  (C) Copyright 2008 - 2015, hehehuyu,Inc.
// -  All Rights Reserved.
//======================================================
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class  Transformation : MonoBehaviour {
    
    public abstract Matrix4x4 Matrix { get; }

    //请注意Matrix4x4。MultiplyPoint具有一个三维矢量参数。它假设缺失的第四个坐标的值是1。它还负责从齐次坐标到欧几里得坐标的转换。如果你想乘以一个方向而不是一个点，你可以使用Matrix4x4.MultiplyVector
    public Vector3 Apply(Vector3 point)
    {
        return Matrix.MultiplyPoint(point);
    } 
}
