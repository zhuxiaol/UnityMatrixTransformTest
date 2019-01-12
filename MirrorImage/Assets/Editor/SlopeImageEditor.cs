//=====================================================
// - FileName:      SlopeImageEditor 
// - Author:        codingriver
// - Created:       2018/12/1 11:10:40
// - CLR version:   4.0.30319.42000
// - UserName:      Administrator
//======================================================

using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using UnityEditor.UI;

[CustomEditor(typeof(SlopeImage))]
public class SlopeImageEditor : ImageEditor
{
    public override void OnInspectorGUI()
    {
        //serializedObject.Update();
        base.OnInspectorGUI();


        EditorGUILayout.PropertyField(m_slopeAngle);
        EditorGUILayout.PropertyField(m_uvSlopeAngle);
        serializedObject.ApplyModifiedProperties();
    }
    SerializedProperty m_slopeAngle;
    SerializedProperty m_uvSlopeAngle;
    //MirrorImage.MirrorType _mirrorType;
    protected override void OnEnable()
    {
        base.OnEnable();
        m_slopeAngle = serializedObject.FindProperty("m_slopeAngle");
        m_uvSlopeAngle = serializedObject.FindProperty("m_uvSlopeAngle");

    }

}

