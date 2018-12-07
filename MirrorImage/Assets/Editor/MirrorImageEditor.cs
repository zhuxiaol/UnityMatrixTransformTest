//=====================================================
// - FileName:      MirrorImageEditor 
// - Author:        codingriver
// - Created:       2018/12/1 11:10:40
// - CLR version:   4.0.30319.42000
// - UserName:      Administrator
//======================================================

using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using UnityEditor.UI;

[CustomEditor(typeof(MirrorImage))]
public class MirrorImageEditor:ImageEditor
{
    public override void OnInspectorGUI()
    {
        //serializedObject.Update();
        base.OnInspectorGUI();


        EditorGUILayout.PropertyField(_mirrorType);
        serializedObject.ApplyModifiedProperties();
    }
    SerializedProperty _mirrorType;
    //MirrorImage.MirrorType _mirrorType;
    protected override void OnEnable()
    {
        base.OnEnable();
        _mirrorType = serializedObject.FindProperty("_mirrorType");
        
    }

}

