//=====================================================
// - FileName:      TestMenuItemEditor.cs
// - Created:       codingriver
//======================================================

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

public class TestMenuItemEditor : MonoBehaviour {

    [InitializeOnLoadMethod]
    static void Init()
    {
        SceneView.onSceneGUIDelegate += OnSceneGUI;
    }
    static void OnSceneGUI(SceneView sceneView)
    {
        Event e = Event.current;
        if (e != null && e.button == 1 && e.type == EventType.MouseUp)
        {
            //右键单击啦，在这里显示菜单
            GenericMenu menu = new GenericMenu();
            menu.AddItem(new GUIContent("菜单项1"), false, OnMenuClick, "menu_1");
            menu.AddItem(new GUIContent("菜单项2"), false, OnMenuClick, "menu_2");
            menu.AddItem(new GUIContent("菜单项3"), false, OnMenuClick, "menu_3");
            menu.ShowAsContext();
        }
    }
    static void OnMenuClick(object userData)
    {
        EditorUtility.DisplayDialog("Tip", "OnMenuClick" + userData.ToString(), "Ok");
    }


    [MenuItem("Tools/Test", false)]
    public static void Create(MenuCommand menuCommand)
    {
        GameObject parent = menuCommand.context as GameObject;
    }

    /*
     * 这里注意 priority参数，值要控制在-10到49之间
     */
    [MenuItem("GameObject/Tes1", false, 0)]
    public static void Create1()
    {

    }

    [MenuItem("Assets/Tes2", false)]
    public static void Create2()
    {
    }
}
