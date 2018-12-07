//=====================================================
// - FileName:      MirrorImage 
// - Author:        codingriver
// - Created:       2018/11/30 19:28:04
// - CLR version:   4.0.30319.42000
// - UserName:      Administrator
//======================================================

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


[AddComponentMenu("UI/Effects/MirrorImage1", 20)]
[RequireComponent(typeof(Graphic))]
public class MirrorImage1 : BaseMeshEffect
{
    public enum MirrorType
    {
        /// <summary>
        /// 水平
        /// </summary>
        Horizontal,

        /// <summary>
        /// 垂直
        /// </summary>
        Vertical,

        /// <summary>
        /// 四分之一
        /// 相当于水平，然后再垂直
        /// </summary>
        Quarter
    }


    /// <summary>
    /// 镜像类型
    /// </summary>
    [SerializeField]
    private MirrorType m_MirrorType = MirrorType.Horizontal;

    public MirrorType mirrorType
    {
        get { return m_MirrorType; }
        set
        {
            if (m_MirrorType != value)
            {
                m_MirrorType = value;
                if (graphic != null)
                {
                    graphic.SetVerticesDirty();
                }
            }
        }
    }

    private RectTransform m_RectTransform;

    public RectTransform rectTransform
    {
        get { return m_RectTransform ?? (m_RectTransform = GetComponent<RectTransform>()); }
    }

    /// <summary>
    /// 设置原始尺寸
    /// </summary>
    public void SetNativeSize()
    {
        if (graphic != null && graphic is Image)
        {
            Sprite overrideSprite = (graphic as Image).overrideSprite;

            if (overrideSprite != null)
            {
                float w = overrideSprite.rect.width / (graphic as Image).pixelsPerUnit;
                float h = overrideSprite.rect.height / (graphic as Image).pixelsPerUnit;
                rectTransform.anchorMax = rectTransform.anchorMin;

                switch (m_MirrorType)
                {
                    case MirrorType.Horizontal:
                        rectTransform.sizeDelta = new Vector2(w * 2, h);
                        break;
                    case MirrorType.Vertical:
                        rectTransform.sizeDelta = new Vector2(w, h * 2);
                        break;
                    case MirrorType.Quarter:
                        rectTransform.sizeDelta = new Vector2(w * 2, h * 2);
                        break;
                }

                graphic.SetVerticesDirty();
            }
        }
    }


    public string ToString1(UIVertex v)
    {

       return string.Format("{0},{1},{2}",v.position,v.uv0,v.uv1,v.uv2);

    }


    public void ModifyMesh1(VertexHelper vh)
    {
        var output = new List<UIVertex>();
        vh.GetUIVertexStream(output);
        for (int i = 0; i < output.Count; i++)
        {
            
            Debug.Log(ToString1(output[i]));
        }
        




        Image img = (graphic as Image);
        Image.Type type = img.type;


        vh.Clear();
        vh.AddUIVertexTriangleStream(output);
    }



    public override void ModifyMesh(VertexHelper vh)
    {
        if (!IsActive())
        {
            return;
        }

        var output = new List<UIVertex>();
        vh.GetUIVertexStream(output);

        int count = output.Count;

        if (graphic is Image)
        {
            Image.Type type = (graphic as Image).type;

            switch (type)
            {
                case Image.Type.Simple:
                    DrawSimple(output, count);
                    break;
                case Image.Type.Sliced:
                    DrawSliced(output, count);
                    break;
                case Image.Type.Tiled:

                    break;
                case Image.Type.Filled:

                    break;
            }
        }
        else
        {
            DrawSimple(output, count);
        }

        vh.Clear();
        vh.AddUIVertexTriangleStream(output);

        //ListPool<UIVertex>.Recycle(output);
    }

    /// <summary>
    /// 绘制简单版
    /// </summary>
    /// <param name="output"></param>
    /// <param name="count"></param>
    protected void DrawSimple(List<UIVertex> output, int count)
    {
        Debug.Log("out put count:" + count+"  count::"+output.Count);
        Rect rect = graphic.GetPixelAdjustedRect();

        SimpleScale(rect, output, count);

        switch (m_MirrorType)
        {
            case MirrorType.Horizontal:
                //ExtendCapacity(output, count);
                MirrorVerts(rect, output, count, true);
                break;
            case MirrorType.Vertical:
                //ExtendCapacity(output, count);
                MirrorVerts(rect, output, count, false);
                break;
            case MirrorType.Quarter:
                //ExtendCapacity(output, count * 3);
                MirrorVerts(rect, output, count, true);
                MirrorVerts(rect, output, count * 2, false);
                break;
        }
    }

    protected void SimpleScale(Rect rect, List<UIVertex> verts, int count)
    {
        for (int i = 0; i < count; i++)
        {
            UIVertex vertex = verts[i];

            Vector3 position = vertex.position;

            if (m_MirrorType == MirrorType.Horizontal || m_MirrorType == MirrorType.Quarter)
            {
                position.x = (position.x + rect.x) * 0.5f;
            }

            if (m_MirrorType == MirrorType.Vertical || m_MirrorType == MirrorType.Quarter)
            {
                position.y = (position.y + rect.y) * 0.5f;
            }

            vertex.position = position;

            verts[i] = vertex;
        }
    }

    /// <summary>
    /// Sliced缩放位移顶点（减半）
    /// </summary>
    /// <param name="rect"></param>
    /// <param name="verts"></param>
    /// <param name="count"></param>
    protected void SlicedScale(Rect rect, List<UIVertex> verts, int count)
    {
        Rect rect1 = graphic.GetPixelAdjustedRect();

        Sprite overrideSprite = (graphic as Image).overrideSprite;
        Vector4 border = GetAdjustedBorders(overrideSprite.border, rect1);
        
            

        float halfWidth = rect.width * 0.5f;

        float halfHeight = rect.height * 0.5f;

        for (int i = 0; i < count; i++)
        {
            UIVertex vertex = verts[i];

            Vector3 position = vertex.position;

            if (m_MirrorType == MirrorType.Horizontal || m_MirrorType == MirrorType.Quarter)
            {
                if (halfWidth < border.x && position.x >= rect.center.x)
                {
                    position.x = rect.center.x;
                }
                else if (position.x >= border.x)
                {
                    position.x = (position.x + rect.x) * 0.5f;
                }
            }

            if (m_MirrorType == MirrorType.Vertical || m_MirrorType == MirrorType.Quarter)
            {
                if (halfHeight < border.y && position.y >= rect.center.y)
                {
                    position.y = rect.center.y;
                }
                else if (position.y >= border.y)
                {
                    position.y = (position.y + rect.y) * 0.5f;
                }
            }

            vertex.position = position;

            verts[i] = vertex;
        }
    }

    /// <summary>
    /// 绘制Sliced版
    /// </summary>
    /// <param name="output"></param>
    /// <param name="count"></param>
    protected void DrawSliced(List<UIVertex> output, int count)
    {
        //sprite的border为零的情况下，遵从Image的设定，按照Simple模式绘制。
        if (!(graphic as Image).hasBorder)
        {
            DrawSimple(output, count);

            return;
        }

        Rect rect = graphic.GetPixelAdjustedRect();

        SlicedScale(rect, output, count);

        //TODO：

        switch (m_MirrorType)
        {
            case MirrorType.Horizontal:
                //ExtendCapacity(output, count);
                MirrorVerts(rect, output, count, true);
                break;
            case MirrorType.Vertical:
                //ExtendCapacity(output, count);
                MirrorVerts(rect, output, count, false);
                break;
            case MirrorType.Quarter:
                //ExtendCapacity(output, count * 3);
                MirrorVerts(rect, output, count, true);
                MirrorVerts(rect, output, count * 2, false);
                break;
        }
    }

    /// <summary>
    /// 清理掉不能成三角面的顶点
    /// </summary>
    /// <param name="verts"></param>
    /// <param name="count"></param>
    /// <returns></returns>
    protected int SliceExcludeVerts(List<UIVertex> verts, int count)
    {
        int realCount = count;

        int i = 0;

        while (i < realCount)
        {
            UIVertex v1 = verts[i];
            UIVertex v2 = verts[i + 1];
            UIVertex v3 = verts[i + 2];

            if (v1.position == v2.position || v2.position == v3.position || v3.position == v1.position)
            {
                verts[i] = verts[realCount - 3];
                verts[i + 1] = verts[realCount - 2];
                verts[i + 2] = verts[realCount - 1];

                realCount -= 3;
                continue;
            }

            i += 3;
        }

        if (realCount < count)
        {
            verts.RemoveRange(realCount, count - realCount);
        }

        return realCount;
    }


    protected void MirrorVerts(Rect rect, List<UIVertex> verts, int count, bool isHorizontal = true)
    {
        for (int i = 0; i < count; i++)
        {
            UIVertex vertex = verts[i];

            Vector3 position = vertex.position;

            if (isHorizontal)
            {
                position.x = rect.center.x * 2 - position.x;
            }
            else
            {
                position.y = rect.center.y * 2 - position.y;
            }

            vertex.position = position;

            verts.Add(vertex);
        }
    }



    private Vector4 GetAdjustedBorders(Vector4 border, Rect adjustedRect)
    {
        Rect originalRect = rectTransform.rect;

        for (int axis = 0; axis <= 1; axis++)
        {
            float borderScaleRatio;

            // The adjusted rect (adjusted for pixel correctness)
            // may be slightly larger than the original rect.
            // Adjust the border to match the adjustedRect to avoid
            // small gaps between borders (case 833201).
            if (originalRect.size[axis] != 0)
            {
                borderScaleRatio = adjustedRect.size[axis] / originalRect.size[axis];
                border[axis] *= borderScaleRatio;
                border[axis + 2] *= borderScaleRatio;
            }

            // If the rect is smaller than the combined borders, then there's not room for the borders at their normal size.
            // In order to avoid artefacts with overlapping borders, we scale the borders down to fit.
            float combinedBorders = border[axis] + border[axis + 2];
            if (adjustedRect.size[axis] < combinedBorders && combinedBorders != 0)
            {
                borderScaleRatio = adjustedRect.size[axis] / combinedBorders;
                border[axis] *= borderScaleRatio;
                border[axis + 2] *= borderScaleRatio;
            }
        }
        return border;
    }

}

