//=====================================================
// - FileName:    	#SCRIPTNAME#.cs
// - Created:		#AuthorName#
// - UserName:		#CreateTime#
// - Email:			#AuthorEmail#
// - Description:	
// -  (C) Copyright 2008 - 2015, hehehuyu,Inc.
// -  All Rights Reserved.
//======================================================
using UnityEngine;
using System.Collections;
using System.IO;

public class Copyright: UnityEditor.AssetModificationProcessor
{
    private const string AuthorName="wangguoqing";
    private const string AuthorEmail = "wangguoqing@hehegames.cn";

    private const string DateFormat = "yyyy/MM/dd HH:mm:ss";
    private static void OnWillCreateAsset(string path)
    {
        path = path.Replace(".meta", "");
        if (path.EndsWith(".cs"))
        {
            string allText = File.ReadAllText(path);
            allText = allText.Replace("#AuthorName#", AuthorName);
            allText = allText.Replace("#AuthorEmail#", AuthorEmail);
            allText = allText.Replace("#CreateTime#", System.DateTime.Now.ToString(DateFormat));            
            File.WriteAllText(path, allText);
            UnityEditor.AssetDatabase.Refresh();
        }

    }
}