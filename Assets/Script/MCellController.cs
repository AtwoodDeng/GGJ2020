using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MCellController : MonoBehaviour
{
    public int rowCount = 20;
    public int columeCount = 20;
    public float cellSize = 2f;

    public GameObject cellPrefab;

    public void Start()
    {
        for ( int i = 0; i < rowCount; ++ i )
            for ( int j = 0; j < columeCount; ++ j )
            {
                var cell = Instantiate(cellPrefab) as GameObject;

                cell.transform.parent = transform;

                cell.transform.localPosition = new Vector3(i, j, 0) * cellSize;
            }
    }
}
