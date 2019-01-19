//=====================================================
// - FileName:      Singleton 
// - Author:        codingriver
// - Created:       2018/11/13 15:56:29
// - CLR version:   4.0.30319.42000
// - UserName:      Administrator
//======================================================

using System;
using UnityEngine;


    /// <summary>
    /// 单例
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class Singleton<T> :MonoBehaviour
        where T : MonoBehaviour
    {
        private static T m_Instance;
        private static object locker = new object();
        public static T Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    lock (locker)
                    {
                        if(m_Instance==null)
                        {
                            GameObject obj = new GameObject(typeof(T).Name);
                            GameObject.DontDestroyOnLoad(obj);
                            m_Instance = obj.AddComponent<T>();
                        }
                    }

                }
                return m_Instance;

            }
        }
        public Singleton()
        {
            if (m_Instance != null)
            {
                throw (new Exception("Can't create singleton instance more than once."));
            }
        }

        public void Dispose()
        {
            m_Instance = default(T);
        }




    }

