using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformationMatrixUtil {

	
    /// <summary>
    /// 平移变换，缩放变换，旋转变换
    /// </summary>
    /// <param name="scale"></param>
    /// <param name="rotation"></param>
    /// <param name="translate"></param>
    /// <param name="currentPos"></param>
    /// <returns></returns>
    public static Vector3 MToWPosition(Vector3 scale, Vector3 rotation, Vector3 translate, Vector3 currentPos)
    {
        Matrix4x4 convertMatrix = MToWMatrix(scale, rotation, translate);
        Vector3 pos= convertMatrix.MultiplyPoint(currentPos);
        return pos;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="scale"></param>
    /// <param name="rotation"></param>
    /// <param name="translate"></param>
    /// <param name="currentPos"></param>
    /// <returns></returns>
    public static Vector3 WToMPosition(Vector3 scale, Vector3 rotation, Vector3 translate, Vector3 currentPos)
    {
        Matrix4x4 convertMatrix = MToWMatrix(scale, rotation, translate);
        Vector3 pos = convertMatrix.inverse.MultiplyPoint(currentPos);
        return pos;
    }

    /// <summary>
    /// 模型空间到世界空间的变换矩阵
    /// </summary>
    /// <param name="scale"></param>
    /// <param name="rotation"></param>
    /// <param name="translate"></param>
    /// <returns></returns>
    public static Matrix4x4 MToWMatrix(Vector3 scale, Vector3 rotation, Vector3 translate)
    {
        Matrix4x4 scaleMatrix = new Matrix4x4();
        scaleMatrix.SetRow(0, new Vector4(scale.x, 0, 0, 0));
        scaleMatrix.SetRow(1, new Vector4(0, scale.y, 0, 0));
        scaleMatrix.SetRow(2, new Vector4(0, 0, scale.z, 0));
        scaleMatrix.SetRow(3, new Vector4(0, 0, 0, 1));

        rotation *= Mathf.Deg2Rad;
        Matrix4x4 rotateMatrixZ = new Matrix4x4();
        rotateMatrixZ.SetRow(0, new Vector4(Mathf.Cos(rotation.z), -Mathf.Sin(rotation.z), 0, 0));
        rotateMatrixZ.SetRow(1, new Vector4(Mathf.Sin(rotation.z), Mathf.Cos(rotation.z), 0, 0));
        rotateMatrixZ.SetRow(2, new Vector4(0, 0, 1, 0));
        rotateMatrixZ.SetRow(3, new Vector4(0, 0, 0, 1));

        Matrix4x4 rotateMatrixY = new Matrix4x4();
        rotateMatrixY.SetRow(0, new Vector4(Mathf.Cos(rotation.y), 0, Mathf.Sin(rotation.y), 0));
        rotateMatrixY.SetRow(1, new Vector4(0, 1, 0, 0));
        rotateMatrixY.SetRow(2, new Vector4(-Mathf.Sin(rotation.y), 0, Mathf.Cos(rotation.y), 0));
        rotateMatrixY.SetRow(3, new Vector4(0, 0, 0, 1));

        Matrix4x4 rotateMatrixX = new Matrix4x4();
        rotateMatrixX.SetRow(0, new Vector4(1, 0, 0, 0));
        rotateMatrixX.SetRow(1, new Vector4(0, Mathf.Cos(rotation.x), -Mathf.Sin(rotation.x), 0));
        rotateMatrixX.SetRow(2, new Vector4(0, Mathf.Sin(rotation.x), Mathf.Cos(rotation.x), 0));
        rotateMatrixX.SetRow(3, new Vector4(0, 0, 0, 1));

        Matrix4x4 translateMatrix = new Matrix4x4();
        translateMatrix.SetRow(0, new Vector4(1, 0, 0, translate.x));
        translateMatrix.SetRow(1, new Vector4(0, 1, 0, translate.y));
        translateMatrix.SetRow(2, new Vector4(0, 0, 1, translate.z));
        translateMatrix.SetRow(3, new Vector4(0, 0, 0, 1));

        Matrix4x4 convertMatrix = translateMatrix * rotateMatrixY * rotateMatrixX * rotateMatrixZ * scaleMatrix;
        return convertMatrix;
    }


    /// <summary>
    /// 世界空间 转到 观察空间
    /// </summary>
    /// <param name="worldPos"></param>
    /// <returns></returns>
    public static Vector3 WToVPosition(Vector3 worldPos)
    {

        Matrix4x4 mat = WToVMatrix();
        Vector3 viewPos = mat.MultiplyPoint(worldPos);
        return viewPos;
    }

    public static Matrix4x4 WToVMatrix()
    {
        Transform camTrans = Camera.main.transform;
        Matrix4x4 matrix = MToWMatrix(camTrans.localScale, camTrans.localEulerAngles, camTrans.position);
        Matrix4x4 inverseMatrix = matrix.inverse;

        //观察空间是右手坐标系
        inverseMatrix.SetRow(2, -inverseMatrix.GetRow(2));
        return inverseMatrix;
    }

    /// <summary>
    /// 观察空间到裁剪空间
    /// 
    /// </summary>
    /// <param name="vPos"></param>
    /// <returns></returns>
    public static Vector4 VToPPosition(Vector3 vPos)
    {

        Matrix4x4 matrix = VToPMatrix();
        Vector4 p = matrix*new Vector4( vPos.x,vPos.y,vPos.z,1);
        return p;
    }
    public static Matrix4x4 VToPMatrix()
    {
        Camera cam = Camera.main;
        float near = cam.nearClipPlane;
        float far = cam.farClipPlane;
        float fov = cam.fieldOfView;
        float aspect = cam.aspect;
        Matrix4x4 matrix = VToPMatrix(fov, near, far, aspect);
        return matrix;
    }
    /// <summary>
    /// 透视裁剪矩阵
    /// 透视投影矩阵
    /// 参考（https://blog.csdn.net/cbbbc/article/details/51296804）
    /// View to Projection
    /// 观察空间到裁剪空间
    /// </summary>
    /// <param name="fov"></param>
    /// <param name="near"></param>
    /// <param name="far"></param>
    /// <param name="aspect"></param>
    /// <returns></returns>
    public static Matrix4x4 VToPMatrix(float fov,float near,float far,float aspect)
    {
        float tan= Mathf.Tan((fov * Mathf.Deg2Rad) / 2);

        Matrix4x4 matrix = new Matrix4x4();
        matrix.SetRow(0, new Vector4(1 / (aspect * tan), 0, 0, 0));
        matrix.SetRow(1, new Vector4(0,1 / (tan), 0, 0));
        matrix.SetRow(2, new Vector4(0, 0, -(far + near) / (far - near), -2 * far * near / (far - near)));
        matrix.SetRow(3, new Vector4(0, 0, -1, 0));

        return matrix;
    }
    /// <summary>
    /// NDC是一个归一化的空间，坐标空间范围为[-1, 1]。从Projection空间到NDC空间的做法就是做了一个齐次除法！
    /// Projection to NDC
    /// </summary>
    /// <param name="p"></param>
    /// <returns></returns>
    public static Vector4 PToNDCPosition(Vector4 p)
    {
        return p / p.w;
    }
    /// <summary>
    /// NDC - Texture Space
    /// (NDC - Viewport Space 视口空间,z的值这里和视口空间不一样，z的范围是[-1,1],视口坐标的z值是实际的z值)
    /// 这个过程是将[-1, 1]映射到[0, 1]之间。
    /// NDC to Texture space
    /// </summary>
    /// <param name="p"></param>
    /// <returns></returns>
    public static Vector4 NDCToTexturePosition(Vector4 ndcPoint)
    {
        //return new Vector4((ndcPoint.x + 1) / 2, (ndcPoint.y + 1) / 2, ndcPoint.z, ndcPoint.w);
        return (ndcPoint + Vector4.one) / 2;
    }

    /// <summary>
    /// Texture Space - Screen Space
    /// 这个过程就是得到顶点最终在屏幕上的坐标，其实就是利用Texture Space的坐标乘上屏幕的宽高。
    /// Texture to Screen
    /// </summary>
    /// <param name="p"></param>
    /// <returns></returns>
    public static Vector4 TextureToScreenPosition(Vector4 texturePoint)
    {
        Vector4 screenPos = new Vector4(texturePoint.x * Screen.width, texturePoint.y * Screen.height, texturePoint.z, texturePoint.w);
        return screenPos;
    }

}
