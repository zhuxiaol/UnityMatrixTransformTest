//=====================================================
// - FileName:      SlopeImage 
// - Author:        codingriver
// - Created:       2018/11/30 21:12:51
// - CLR version:   4.0.30319.42000
// - UserName:      Administrator
//======================================================

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Sprites;
[AddComponentMenu("UI/SlopeImage", 20)]
public class SlopeImage : Image
{

    [SerializeField]
    private float m_slopeAngle = 0;

    public float slopeAngle
    {
        get
        {
            return m_slopeAngle;
        }
        set
        {
            if(value>360)
            {
                value = value % 360;
            }
            m_tanV = Mathf.Tan(value* Mathf.Deg2Rad);
            m_slopeAngle = value;
        }
    }

    private float m_tanV=0;

    [SerializeField]
    private float m_uvSlopeAngle;
    public float uvSlopeAngle
    {
        get
        {
            return m_uvSlopeAngle;
        }
        set
        {
            if (value > 360)
            {
                value = value % 360;
            }
            m_uvTanV = Mathf.Tan(value * Mathf.Deg2Rad);
            m_uvSlopeAngle = value;
        }
    }

    private float m_uvTanV = 0;

    


    protected override void OnPopulateMesh(VertexHelper toFill)
    {
        Sprite _sprite = overrideSprite != null ? overrideSprite : sprite;
        if (_sprite == null)
        {
            base.OnPopulateMesh(toFill);
            return;
        }

        switch (type)
        {
            case Type.Simple:
                //GenerateSimpleSprite(toFill, preserveAspect);
                break;
            case Type.Sliced:
                //GenerateSlicedSprite(toFill);
                break;
            case Type.Tiled:
                //GenerateTiledSprite(toFill);
                break;
            case Type.Filled:
                GenerateFilledSprite(toFill, preserveAspect);
                break;
        }
    }

    static readonly Vector3[] s_Xy = new Vector3[4];
    static readonly Vector3[] s_Uv = new Vector3[4];
    void GenerateFilledSprite(VertexHelper toFill, bool preserveAspect)
    {
        m_tanV = Mathf.Tan(m_slopeAngle * Mathf.Deg2Rad);
        m_uvTanV = Mathf.Tan(m_uvSlopeAngle * Mathf.Deg2Rad);
        toFill.Clear();

        if (fillAmount < 0.001f)
            return;

        //   xw---------zw
        //   |           |
        //   |           |
        //   |           |
        //   xy---------zy
        Vector4 v = GetDrawingDimensions(preserveAspect);
        Vector4 tmp_v = v;
        Vector4 outer = sprite != null ? DataUtility.GetOuterUV(sprite) : Vector4.zero;
        UIVertex uiv = UIVertex.simpleVert;
        uiv.color = color;

        float tx0 = outer.x;
        float ty0 = outer.y;
        float tx1 = outer.z;
        float ty1 = outer.w;
        

        // Horizontal and vertical filled sprites are simple -- just end the Image prematurely
        if (fillMethod == FillMethod.Horizontal || fillMethod == FillMethod.Vertical)
        {
            if (fillMethod == FillMethod.Horizontal)
            {
                float fill = (tx1 - tx0) * fillAmount;

                if (fillOrigin == 1)
                {
                    v.x = v.z - (v.z - v.x) * fillAmount;
                    tx0 = tx1 - fill;
                }
                else
                {
                    v.z = v.x + (v.z - v.x) * fillAmount;
                    tx1 = tx0 + fill;
                }
            }
            else if (fillMethod == FillMethod.Vertical)
            {
                float fill = (ty1 - ty0) * fillAmount;

                if (fillOrigin == 1)
                {
                    v.y = v.w - (v.w - v.y) * fillAmount;
                    ty0 = ty1 - fill;
                }
                else
                {
                    v.w = v.y + (v.w - v.y) * fillAmount;
                    ty1 = ty0 + fill;
                }
            }
        }


        Debug.Log( "  fillOrigin:" + fillOrigin + "  tan:" + m_tanV + " tmp_v:" + tmp_v+" tx0:"+tx0+" ty0:"+ty0+" tx1:"+tx1+" ty1:"+ty1);

        float offset = m_tanV * (tmp_v.w - tmp_v.y);
        s_Xy[0] = new Vector2(v.x, v.y);
        s_Xy[1] = new Vector2(v.x+ offset, v.w);
        s_Xy[2] = new Vector2(v.z , v.w);
        s_Xy[3] = new Vector2(v.z- offset, v.y);

        //float uvOffset = offset / (tmp_v.w - tmp_v.y);
        //float uvOffset = m_tanV* (tx1- tx0);
        float uvOffset = m_uvTanV * (ty1 - ty0);
        Debug.Log(" offset:"+offset+"  tanV:"+m_tanV+" uvOffset:"+uvOffset);
        s_Uv[0] = new Vector2(tx0, ty0);
        s_Uv[1] = new Vector2(tx0 + uvOffset, ty1);
        s_Uv[2] = new Vector2(tx1, ty1);
        //s_Uv[1] = new Vector2(tx0 , ty1);
        //s_Uv[2] = new Vector2(tx1 , ty1);
        s_Uv[3] = new Vector2(tx1- uvOffset, ty0);

        {
            if (fillMethod == FillMethod.Horizontal)
            {
                AddQuad(toFill, s_Xy, color, s_Uv);
            }
            else
            {
                throw new UnityException("fillmethod only support Horizontal!");
            }
        }
    }
    static void AddQuad(VertexHelper vertexHelper, Vector3[] quadPositions, Color32 color, Vector3[] quadUVs)
    {
        int startIndex = vertexHelper.currentVertCount;

        for (int i = 0; i < 4; ++i)
            vertexHelper.AddVert(quadPositions[i], color, quadUVs[i]);

        vertexHelper.AddTriangle(startIndex, startIndex + 1, startIndex + 2);
        vertexHelper.AddTriangle(startIndex + 2, startIndex + 3, startIndex);
    }
    /// Image's dimensions used for drawing. X = left, Y = bottom, Z = right, W = top.
    private Vector4 GetDrawingDimensions(bool shouldPreserveAspect)
    {
        var padding = sprite == null ? Vector4.zero : DataUtility.GetPadding(sprite);
        var size = sprite == null ? Vector2.zero : new Vector2(sprite.rect.width, sprite.rect.height);

        Rect r = GetPixelAdjustedRect();
        // Debug.Log(string.Format("r:{2}, size:{0}, padding:{1}", size, padding, r));

        int spriteW = Mathf.RoundToInt(size.x);
        int spriteH = Mathf.RoundToInt(size.y);

        var v = new Vector4(
                padding.x / spriteW,
                padding.y / spriteH,
                (spriteW - padding.z) / spriteW,
                (spriteH - padding.w) / spriteH);

        if (shouldPreserveAspect && size.sqrMagnitude > 0.0f)
        {
            var spriteRatio = size.x / size.y;
            var rectRatio = r.width / r.height;

            if (spriteRatio > rectRatio)
            {
                var oldHeight = r.height;
                r.height = r.width * (1.0f / spriteRatio);
                r.y += (oldHeight - r.height) * rectTransform.pivot.y;
            }
            else
            {
                var oldWidth = r.width;
                r.width = r.height * spriteRatio;
                r.x += (oldWidth - r.width) * rectTransform.pivot.x;
            }
        }

        v = new Vector4(
                r.x + r.width * v.x,
                r.y + r.height * v.y,
                r.x + r.width * v.z,
                r.y + r.height * v.w
                );

        return v;
    }




    //public override void SetNativeSize()
    //{
    //    if (sprite != null)
    //    {
    //        float w = sprite.rect.width / pixelsPerUnit;
    //        float h = sprite.rect.height / pixelsPerUnit;
    //        if (mirrorType== MirrorType.Horizontal)
    //        {
    //            w *= 2;
    //        }
    //        else if (mirrorType == MirrorType.Vertical)
    //        {
    //            h *= 2;
    //        }
    //        else
    //        {
    //            w *= 2;
    //            h *= 2;
    //        }

    //        rectTransform.anchorMax = rectTransform.anchorMin;
    //        rectTransform.sizeDelta = new Vector2(w, h);
    //        SetAllDirty();
    //    }
    //}



}

