//=====================================================
// - FileName:      AstarFind.cs
// - Created:       codingriver
// - UserName:      2018/10/19 15:18:38
// - Blog:			https://blog.csdn.net/codingriver
//======================================================

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


/// <summary>
/// A*算法寻路
/// </summary>
public class AstarFind : MonoBehaviour {


    AstarGrid grid;
    void Start()
    {
        grid = GetComponent<AstarGrid>();
        FindPath(grid.startPos, grid.endPos);
    }


    List<Cell> openLs = new List<Cell>();
    List<Cell> closeLs = new List<Cell>();


    /// <summary>
    /// 使用A*算法寻路
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    void FindPath(Vector2 start,Vector2 end)
    {
        Cell startCell = grid.GetCell(start);
        Cell endCell = grid.GetCell(end);
        Debug.LogFormat("寻路开始,start({0}),end({1})!",start,end);
        openLs.Add(startCell);

        while(openLs.Count>0)
        {
            Cell cur = openLs[0];
            for (int i = 0; i < openLs.Count; i++)
            {
                if(openLs[i].fCost<cur.fCost&&openLs[i].hCost<cur.hCost)
                {
                    cur = openLs[i];
                }
            }
            Debug.Log("cur::::::::::::::::::::::" + cur.ToString());
            openLs.Remove(cur);
            closeLs.Add(cur);

            if(cur==endCell)
            {
                Debug.Log("寻路结束!");
                grid.CreatePath(cur);
                return;
            }


            List<Cell> aroundCells = GetAllAroundCells(cur);

            foreach (var cell in aroundCells)
            {
                if (cell.isWall || closeLs.Contains(cell))
                    continue;

                int cost= cur.gCost+ GetDistanceCost(cell, cur);

                if(cost<cell.gCost||!openLs.Contains(cell))
                {
                    cell.gCost = cost;
                    cell.hCost = GetDistanceCost(cell,endCell);
                    cell.parent = cur;
                    Debug.Log("cell:" + cell.ToString() + "  parent:" + cur.ToString() + "  " + cell.PrintCost());
                    if(!openLs.Contains(cell))
                    {
                        openLs.Add(cell);
                    }

                }


            }

        }
    }


    // 取得周围的节点
    public List<Cell> GetAllAroundCells(Cell cell)
    {
        List<Cell> list = new List<Cell>();
        for (int i = -1; i <= 1; i++)
        {
            for (int j = -1; j <= 1; j++)
            {
                // 如果是自己，则跳过
                if (i == 0 && j == 0)
                    continue;
                int x = cell.x + i;
                int y = cell.y + j;
                // 判断是否越界，如果没有，加到列表中
                if (x < grid.gridSize && x >= 0 && y < grid.gridSize && y >= 0)
                {
                    list.Add(grid.GetCell(new Vector2(x,y)));
                }
                    
            }
        }
        return list;
    }


    // 获取两个节点之间的距离
    int GetDistanceCost(Cell a, Cell b)
    {
        int cntX = Mathf.Abs(a.x - b.x);
        int cntY = Mathf.Abs(a.y - b.y);
        // 判断到底是那个轴相差的距离更远
        if (cntX > cntY)
        {
            return 14 * cntY + 10 * (cntX - cntY);
        }
        else
        {
            return 14 * cntX + 10 * (cntY - cntX);
        }
    }






}
